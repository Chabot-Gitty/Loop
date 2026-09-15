//
//  NocturneSettingsSheet.swift
//  Loop
//
//  Created by Claude on 2026-09-15.
//  Copyright © 2026 LoopKit Authors. All rights reserved.
//

import SwiftUI
import LoopKit

struct NocturneSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var baseURLText: String = ""
    @State private var apiToken: String = ""

    let onSave: () -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Nocturne")) {
                    TextField("https://nocturne.example.com", text: $baseURLText)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    SecureField("API token", text: $apiToken)
                }
            }
            .navigationTitle("Nocturne Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(URL(string: baseURLText) == nil || apiToken.isEmpty)
                }
            }
        }
    }

    private func save() {
        guard let url = URL(string: baseURLText) else { return }
        try? KeychainManager().setNocturneCredentials(baseURL: url, apiToken: apiToken)
        onSave()
        dismiss()
    }
}
