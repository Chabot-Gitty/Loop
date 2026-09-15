//
//  NocturneFavoritesSectionContent.swift
//  Loop
//
//  Created by Claude on 2026-09-15.
//  Copyright © 2026 LoopKit Authors. All rights reserved.
//

import SwiftUI

struct NocturneFavoritesSectionContent: View {
    @ObservedObject var viewModel: NocturneFavoritesSectionViewModel
    @State private var isShowingSettings = false

    var body: some View {
        Group {
            switch viewModel.state {
            case .notConfigured:
                Button("Configure Nocturne") {
                    isShowingSettings = true
                }
            case .loading:
                HStack {
                    ProgressView()
                    Text("Loading from Nocturne...")
                }
            case .loaded(let foods) where foods.isEmpty:
                Text("No favorites found in Nocturne.")
                    .foregroundColor(.secondary)
            case .loaded(let foods):
                ForEach(foods) { food in
                    VStack(alignment: .leading) {
                        Text(food.name)
                        Text("\(Int(food.carbs))g carbs per \(food.portion.formatted()) \(food.unit)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            case .error(let message):
                Text(message)
                    .foregroundColor(.red)
            }
        }
        .sheet(isPresented: $isShowingSettings) {
            NocturneSettingsSheet {
                Task { await viewModel.refresh() }
            }
        }
    }
}
