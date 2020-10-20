//
//  ErrorHandling.swift
//  Social
//
//  Created by Nikita Evstigneev on 11/09/2020.
//

import SwiftUI

// MARK: - Interface

public protocol ErrorHandler {
    func handle<T: View>(_ error: Binding<Error?>, in view: T, retryHandler: (() -> Void)?) -> AnyView
}

// MARK: SwiftUI integration: environment support, modifiers, ...

public struct ErrorHandlerEnvironmentKey: EnvironmentKey {
    public static var defaultValue: ErrorHandler = AlertErrorHandler()
}

public extension EnvironmentValues {
    var errorHandler: ErrorHandler {
        get { self[ErrorHandlerEnvironmentKey.self] }
        set { self[ErrorHandlerEnvironmentKey.self] = newValue }
    }
}

public extension View {
    func handlingErrors(
        using handler: ErrorHandler
    ) -> some View {
        environment(\.errorHandler, handler)
    }
}

public struct ErrorEmittingViewModifier: ViewModifier {
    @Environment(\.errorHandler) var handler
    
    public var error: Binding<Error?>
    public var retryHandler: (() -> Void)?
    
    public func body(content: Content) -> some View {
        handler.handle(
            error,
            in: content,
            retryHandler: retryHandler
        )
    }
}

public extension View {
    func emittingError(
        _ error: Binding<Error?>,
        retryHandler: (() -> Void)? = nil
    ) -> some View {
        modifier(ErrorEmittingViewModifier(
            error: error,
            retryHandler: retryHandler
        ))
    }
}

// MARK: - Alert error handler

public extension Notification.Name {
    
    static var LogoutRequired: Notification.Name {
        Notification.Name(rawValue: "com.astonishingdev.missingswiftui.logout-required")
    }
    
}

public struct AlertErrorHandler: ErrorHandler {
    // We give our handler an ID, so that SwiftUI will be able
    // to keep track of the alerts that it creates as it updates
    // our various views:
    private let id = UUID()
    
    public func handle<T: View>(
        _ error: Binding<Error?>,
        in view: T,
        retryHandler: (() -> Void)?
    ) -> AnyView {
        guard error.wrappedValue?.resolveCategory() != .requiresLogout else {
            NotificationCenter.default.post(name: .LogoutRequired, object: nil)
            return AnyView(view)
        }
        
        var presentation = error.wrappedValue.map { Presentation(
            id: id,
            error: $0,
            retryHandler: retryHandler
        )}
        
        // We need to convert our model to a Binding value in
        // order to be able to present an alert using it:
        let binding = Binding(
            get: { presentation },
            set: {
                presentation = $0
                if $0 == nil {
                    error.wrappedValue = nil
                }
            }
        )
        
        return AnyView(view.alert(item: binding, content: makeAlert))
    }
}

private extension AlertErrorHandler {
    struct Presentation: Identifiable {
        let id: UUID
        let error: Error
        let retryHandler: (() -> Void)?
    }
    
    func makeAlert(for presentation: Presentation) -> Alert {
        let error = presentation.error
        let alertTitle = (error as? UserFriendlyAlertSupportingError)?.alertTitle ?? "An error occured"
        
        switch error.resolveCategory() {
        case .retryable:
            guard let retryHandler = presentation.retryHandler else {
                fallthrough
            }
            return Alert(
                title: Text(alertTitle),
                message: Text(error.localizedDescription),
                primaryButton: .default(Text("Dismiss")),
                secondaryButton: .default(Text("Retry"), action: retryHandler)
            )
        case .nonRetryable:
            return Alert(
                title: Text(alertTitle),
                message: Text(error.localizedDescription),
                dismissButton: .default(Text("Dismiss"))
            )
        case .requiresLogout:
            // We don't expect this code path to be hit, since
            // we're guarding for this case above, so we'll
            // trigger an assertion failure here.
            assertionFailure("Should have logged out")
            return Alert(title: Text("Logging out..."))
        }
    }
}
