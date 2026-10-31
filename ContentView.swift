//
//  ContentView.swift
//  Catalogo Imprenta
//
//  Created by Ximena Alexandra Posada Vazquez on 06/10/26.
//
import SwiftUI
import SwiftData

// MARK: - 1. MODELO DE BASE DE DATOS (SwiftData)
@Model
final class ProductoItem {
    @Attribute(.unique) var id: String
    var nombre: String
    var categoria: String
    var descripcion: String
    var opcionesPersonalizacion: String
    var nombreImagen: String
    var esFavorito: Bool
    
    init(id: String = UUID().uuidString, nombre: String, categoria: String, descripcion: String, opcionesPersonalizacion: String, nombreImagen: String, esFavorito: Bool = false) {
        self.id = id
        self.nombre = nombre
        self.categoria = categoria
        self.descripcion = descripcion
        self.opcionesPersonalizacion = opcionesPersonalizacion
        self.nombreImagen = nombreImagen
        self.esFavorito = esFavorito
    }
}

// MARK: - 2. MODELO DE GALERÍA DE DISEÑOS
struct DisenoEjemplo: Identifiable {
    let id = UUID()
    let titulo: String
    let categoria: String
    let descripcion: String
    let imagenes: [String]
}

// MARK: - 3. VISTA PRINCIPAL (Navegación por TabView)
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query var productos: [ProductoItem]
    
    var body: some View {
        TabView {
            CatalogoProductosView()
                .tabItem {
                    Label("Catálogo", systemImage: "square.grid.2x2.fill")
                }
            
            GaleriaDisenosView()
                .tabItem {
                    Label("Galería", systemImage: "photo.on.rectangle.angled")
                }
            
            FavoritosView()
                .tabItem {
                    Label("Favoritos", systemImage: "heart.fill")
                }
            
            InformacionEmpresaView()
                .tabItem {
                    Label("Empresa", systemImage: "building.2.fill")
                }
        }
        .accentColor(.blue)
        .onAppear {
            cargarDatosInicialesEnBD()
        }
    }
    
    private func cargarDatosInicialesEnBD() {
        if productos.isEmpty {
            let datosBase = [
                ProductoItem(
                    nombre: "Regalos Personalizados",
                    categoria: "Detalles",
                    descripcion: "Tazas sublimadas, playeras personalizadas con estampado de alta duración y cajas de regalo decoradas para todo evento.",
                    opcionesPersonalizacion: "Impresión de nombres, fotografías, logotipos, fechas especiales y diseños personalizados.",
                    nombreImagen: "regalos"
                ),
                ProductoItem(
                    nombre: "Invitaciones Sociales",
                    categoria: "Eventos",
                    descripcion: "Diseños exclusivos e impresiones para bodas, XV años, cumpleaños y eventos corporativos.",
                    opcionesPersonalizacion: "Sobres de color, listones, sellos de lacre y papeles texturizados.",
                    nombreImagen: "invitaciones"
                ),
                ProductoItem(
                    nombre: "Paquete Corporativo",
                    categoria: "Empresas",
                    descripcion: "Kits completos con papelería corporativa, etiquetas adhesivas para empaques y branding empresarial.",
                    opcionesPersonalizacion: "Logotipos, paleta de colores de marca, acabados brillantes o mate.",
                    nombreImagen: "etiquetas"
                ),
                ProductoItem(
                    nombre: "Regalos personalizados",
                    categoria: "Cumpleaños u otro evento",
                    descripcion: "Lienzos personalizados, puzzles, botella personalizada.",
                    opcionesPersonalizacion: "Diseño 100% adaptado al gusto del cliente." ,
                    nombreImagen: "regalos"
                ),
                ProductoItem(
                    nombre: "Diseño Gráfico Profesional",
                    categoria: "Servicios",
                    descripcion: "Creación o modificación de identidades visuales, logotipos y maquetación de archivos.",
                    opcionesPersonalizacion: "Diseño 100% adaptado a las necesidades del cliente.",
                    nombreImagen: "diseno"
                )
            ]
            for item in datosBase {
                modelContext.insert(item)
            }
        }
    }
}

// MARK: - 4. COMPONENTE REUTILIZABLE: BOTÓN WHATSAPP
struct BotonWhatsApp: View {
    var mensaje: String
    
    var body: some View {
        Button(action: {
            abrirWhatsApp(mensaje: mensaje)
        }) {
            HStack {
                Image(systemName: "message.fill")
                Text("Contactar por WhatsApp")
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(radius: 2)
        }
    }
    
    private func abrirWhatsApp(mensaje: String) {
        let telefono = "525561867215"
        let mensajeCodificado = mensaje.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        if let url = URL(string: "https://api.whatsapp.com/send?phone=\(telefono)&text=\(mensajeCodificado)") {
            #if os(iOS)
            UIApplication.shared.open(url)
            #elseif os(macOS)
            NSWorkspace.shared.open(url)
            #endif
        }
    }
}

// MARK: - 5. HELPER DE IMÁGENES
struct ImagenLocalView: View {
    let nombreImagen: String
    var alto: CGFloat = 220
    
    var body: some View {
        Group {
            #if os(iOS)
            if let _ = UIImage(named: nombreImagen) {
                Image(nombreImagen)
                    .resizable()
                    .scaledToFit()
                    .frame(height: alto)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
            } else {
                fallbackView
            }
            #else
            fallbackView
            #endif
        }
    }
    
    private var fallbackView: some View {
        ZStack {
            Color.blue.opacity(0.1)
            Image(systemName: "photo.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(.blue)
        }
        .frame(height: alto)
        .frame(maxWidth: .infinity)
        .cornerRadius(12)
    }
}

// MARK: - 6. MÓDULO 1: CATÁLOGO DE PRODUCTOS
struct CatalogoProductosView: View {
    @Query var productos: [ProductoItem]
    
    var body: some View {
        NavigationView {
            List(productos) { producto in
                NavigationLink(destination: DetalleProductoView(producto: producto)) {
                    HStack(spacing: 15) {
                        ImagenLocalView(nombreImagen: producto.nombreImagen, alto: 50)
                            .frame(width: 50, height: 50)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(producto.nombre)
                                .font(.headline)
                            Text(producto.categoria)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Express Digital")
        }
    }
}

// MARK: - 7. MÓDULO 2: DETALLE DEL PRODUCTO
struct DetalleProductoView: View {
    @Bindable var producto: ProductoItem
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ImagenLocalView(nombreImagen: producto.nombreImagen, alto: 220)
                
                HStack {
                    Text(producto.nombre)
                        .font(.title)
                        .bold()
                    Spacer()
                    Button(action: {
                        producto.esFavorito.toggle()
                    }) {
                        Image(systemName: producto.esFavorito ? "heart.fill" : "heart")
                            .font(.title)
                            .foregroundColor(producto.esFavorito ? .red : .gray)
                    }
                }
                
                Text(producto.categoria)
                    .font(.callout)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Descripción del Servicio")
                        .font(.headline)
                    Text(producto.descripcion)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Opciones de Personalización")
                        .font(.headline)
                    Text(producto.opcionesPersonalizacion)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                BotonWhatsApp(mensaje: "Hola Express Digital, me interesa solicitar informes sobre: \(producto.nombre).")
            }
            .padding()
        }
        .navigationTitle(producto.nombre)
    }
}

// MARK: - 8. MÓDULO 3: GALERÍA DE DISEÑOS (Imágenes independientes de Galería)
struct GaleriaDisenosView: View {
    let ejemplos: [DisenoEjemplo] = [
        DisenoEjemplo(
            titulo: "Tazas Sublimadas Personalizadas",
            categoria: "Regalos",
            descripcion: "Taza cerámica de 11oz con diseño personalizado y acabado brillante de alta duración.",
            imagenes: ["galeria_tazas1", "galeria_tazas2", "galeria_tazas3"] // Imágenes exclusivas para Tazas
        ),
        DisenoEjemplo(
            titulo: "Playeras Estampadas",
            categoria: "Regalos",
            descripcion: "Estampado en vinil textil o DTF para eventos especiales o uniformes empresariales.",
            imagenes: ["galeria_playeras1", "galeria_playeras2", "galeria_playeras3"] // Imágenes exclusivas para Playeras
        ),
        DisenoEjemplo(
            titulo: "Cajas de Regalo Decoradas",
            categoria: "Regalos",
            descripcion: "Cajas de cartón rígido personalizadas con nombres, listones y temática a elección.",
            imagenes: ["galeria_cajas1", "galeria_cajas2", "galeria_cajas3"]
        ),
        DisenoEjemplo(
            titulo: "Invitación Boda Elegante",
            categoria: "Invitaciones",
            descripcion: "Papel albanene con estampado dorado, detalles en relieve y sobre especial.",
            imagenes: ["galeria_bodas1", "galeria_bodas2", "galeria_bodas3"]
        ),
        DisenoEjemplo(
            titulo: "Kit Paquete Corporativo",
            categoria: "Empresas",
            descripcion: "Branding completo con papelería ejecutiva, tarjetas y empaques para negocios.",
            imagenes: ["galeria_kits1", "galeria_kits2", "galeria_kits3"]
        )
    ]
    
    var body: some View {
        NavigationView {
            List(ejemplos) { ejemplo in
                NavigationLink(destination: DetalleDisenoView(ejemplo: ejemplo)) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(ejemplo.titulo)
                            .font(.headline)
                        Text(ejemplo.categoria)
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        Text(ejemplo.descripcion)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    .padding(.vertical, 6)
                }
            }
            .navigationTitle("Ejemplos de Trabajo")
        }
    }
}

struct DetalleDisenoView: View {
    let ejemplo: DisenoEjemplo
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Galería del Proyecto")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(ejemplo.imagenes, id: \.self) { nombreImg in
                                ZStack {
                                    Color.blue.opacity(0.05)
                                    if let _ = UIImage(named: nombreImg) {
                                        Image(nombreImg)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 280, height: 200)
                                            .clipped()
                                    } else {
                                        VStack {
                                            Image(systemName: "photo.fill")
                                                .font(.system(size: 40))
                                                .foregroundColor(.blue)
                                            Text(nombreImg)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                .frame(width: 280, height: 200)
                                .cornerRadius(12)
                                .shadow(radius: 3)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text(ejemplo.titulo)
                        .font(.title2)
                        .bold()
                    
                    Text(ejemplo.categoria)
                        .font(.callout)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                    
                    Text("Descripción")
                        .font(.headline)
                        .padding(.top, 5)
                    
                    Text(ejemplo.descripcion)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                Spacer()
                
                BotonWhatsApp(mensaje: "Hola Express Digital, me gustó este ejemplo de diseño: \(ejemplo.titulo). Me gustaría cotizar algo similar.")
                    .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Detalle del Diseño")
    }
}

// MARK: - 9. MÓDULO 4: FAVORITOS GUARDADOS
struct FavoritosView: View {
    @Query(filter: #Predicate<ProductoItem> { $0.esFavorito }) var favoritos: [ProductoItem]
    
    var body: some View {
        NavigationView {
            Group {
                if favoritos.isEmpty {
                    VStack(spacing: 15) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No tienes productos favoritos guardados.")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                } else {
                    List(favoritos) { producto in
                        NavigationLink(destination: DetalleProductoView(producto: producto)) {
                            HStack {
                                ImagenLocalView(nombreImagen: producto.nombreImagen, alto: 40)
                                    .frame(width: 40, height: 40)
                                Text(producto.nombre)
                                    .font(.headline)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Mis Favoritos")
        }
    }
}

// MARK: - 10. MÓDULO 5: INFORMACIÓN DE LA EMPRESA
struct InformacionEmpresaView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .center, spacing: 10) {
                        Image(systemName: "printer.dotmatrix.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.blue)
                        
                        Text("Express Digital")
                            .font(.largeTitle)
                            .bold()
                        
                        Text("Imprenta y Servicios de Personalización")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(16)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Contacto y Ubicación")
                            .font(.title2)
                            .bold()
                        
                        HStack(alignment: .top) {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(.red)
                            VStack(alignment: .leading) {
                                Text("Dirección:")
                                    .fontWeight(.bold)
                                Text("C. Sor Juana Inés de la Cruz 78 B, Sta María la Ribera, Cuauhtémoc, 06400 Ciudad de México, CDMX")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.orange)
                            VStack(alignment: .leading) {
                                Text("Horarios de Atención:")
                                    .fontWeight(.bold)
                                Text("Lunes a Viernes: 9:00 AM - 6:00 PM\nSábados: 10:00 AM - 2:00 PM")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(16)
                    
                    BotonWhatsApp(mensaje: "Hola Express Digital, quisiera pedir informes generales sobre sus servicios.")
                }
                .padding()
            }
            .navigationTitle("Nosotros")
        }
    }
}
