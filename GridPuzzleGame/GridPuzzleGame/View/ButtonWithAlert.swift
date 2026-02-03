//
//  ButtonWithAlert.swift
//  GridPuzzleGame
//
//  Created by alert on 30/01/26.
//

import SwiftUI

extension ContentView {
    struct ButtonWithAlert: View {
        
        let title: String
        let backgroundColor: Color
        let action: @MainActor () -> Void
        @Binding var isAlertPresented: Bool
        
        var body: some View {
            Button(title) {
                isAlertPresented = true
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(backgroundColor.opacity(0.9))
            .foregroundColor(.white)
            .cornerRadius(8)
            .alert(title, isPresented: $isAlertPresented, actions: {
                Button("OK", role: .destructive, action: action)
                Button("Cancel", role: .cancel) {}
            }, message: {
                Text("You will loose all your progress!")
            })
        }
    }
}

#Preview() {
    ContentView.ButtonWithAlert(title: "Press", backgroundColor: .red, action: {}, isAlertPresented: .constant(true))
}
