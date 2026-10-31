//
//  Catalogo_ImprentaApp.swift
//  Catalogo Imprenta
//
//  Created by Ximena Alexandra Posada Vazquez on 06/10/26.
//
import SwiftUI
import SwiftData

@main
struct CatalogoImprentaApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: ProductoItem.self)
    }
}
