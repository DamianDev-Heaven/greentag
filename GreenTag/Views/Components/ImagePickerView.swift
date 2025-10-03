//
//  ImagePickerView.swift
//  GreenTag
//
//  Created on 03/10/2025.
//

import SwiftUI
import PhotosUI

struct ImagePickerView: View {
    @Binding var selectedImages: [UIImage]
    let maxImages: Int
    let title: String
    var allowsEditing: Bool = true
    var showImageCount: Bool = true
    
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var showingActionSheet = false
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppDimensions.spacingM) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: AppDimensions.spacingXS) {
                    Text(title)
                        .font(AppFonts.titleMedium)
                        .foregroundColor(AppColors.textPrimary)
                    
                    if showImageCount {
                        Text("\(selectedImages.count)/\(maxImages) imágenes")
                            .font(AppFonts.bodySmall)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                Spacer()
                
                if selectedImages.count < maxImages {
                    addImageButton
                }
            }
            
            // Images Grid
            if !selectedImages.isEmpty {
                imagesGrid
            } else {
                emptyState
            }
        }
    }
    
    private var addImageButton: some View {
        Button(action: {
            showingActionSheet = true
            HapticFeedback.light.trigger()
        }) {
            HStack(spacing: AppDimensions.spacingS) {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .medium))
                
                Text("Agregar")
                    .font(AppFonts.labelMedium)
            }
            .padding(.horizontal, AppDimensions.spacingM)
            .padding(.vertical, AppDimensions.spacingS)
            .background(AppColors.primary)
            .foregroundColor(.white)
            .cornerRadius(AppDimensions.cornerRadiusS)
        }
        .confirmationDialog("Seleccionar imagen", isPresented: $showingActionSheet) {
            Button("Cámara") {
                showingCamera = true
            }
            
            Button("Galería") {
                showingImagePicker = true
            }
            
            Button("Cancelar", role: .cancel) { }
        }
    }
    
    private var imagesGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: AppDimensions.spacingM) {
            ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                imageCell(image: image, index: index)
            }
        }
    }
    
    private func imageCell(image: UIImage, index: Int) -> some View {
        ZStack(alignment: .topTrailing) {
            // Image
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 120)
                .clipped()
                .cornerRadius(AppDimensions.cornerRadiusM)
            
            // Remove button
            Button(action: {
                removeImage(at: index)
                HapticFeedback.light.trigger()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Circle())
            }
            .padding(AppDimensions.spacingS)
        }
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var emptyState: some View {
        VStack(spacing: AppDimensions.spacingM) {
            Image(systemName: "photo.badge.plus")
                .font(.system(size: 48))
                .foregroundColor(AppColors.textSecondary)
            
            VStack(spacing: AppDimensions.spacingS) {
                Text("No hay imágenes")
                    .font(AppFonts.titleMedium)
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Toca el botón '+' para agregar imágenes")
                    .font(AppFonts.bodyMedium)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(AppDimensions.cornerRadiusM)
        .onTapGesture {
            showingActionSheet = true
        }
    }
    
    private func removeImage(at index: Int) {
        withAnimation(.easeInOut) {
            selectedImages.remove(at: index)
        }
    }
    
    private func addImages(_ newImages: [UIImage]) {
        let remainingSlots = maxImages - selectedImages.count
        let imagesToAdd = Array(newImages.prefix(remainingSlots))
        
        withAnimation(.easeInOut) {
            selectedImages.append(contentsOf: imagesToAdd)
        }
    }
}

// MARK: - Camera Image Picker
struct CameraImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = true
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraImagePicker
        
        init(_ parent: CameraImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Photo Library Image Picker
struct PhotoLibraryImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    let maxImages: Int
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: PhotoLibraryImagePicker
        
        init(_ parent: PhotoLibraryImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage,
               parent.selectedImages.count < parent.maxImages {
                parent.selectedImages.append(image)
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Single Image Picker
struct SingleImagePicker: View {
    @Binding var selectedImage: UIImage?
    let placeholder: String
    var allowsEditing: Bool = true
    
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var showingActionSheet = false
    
    var body: some View {
        Button(action: {
            showingActionSheet = true
            HapticFeedback.light.trigger()
        }) {
            ZStack {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipped()
                        .cornerRadius(AppDimensions.cornerRadiusM)
                } else {
                    VStack(spacing: AppDimensions.spacingM) {
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 40))
                            .foregroundColor(AppColors.textSecondary)
                        
                        Text(placeholder)
                            .font(AppFonts.bodyMedium)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(AppDimensions.cornerRadiusM)
                }
            }
        }
        .confirmationDialog("Seleccionar imagen", isPresented: $showingActionSheet) {
            Button("Cámara") {
                showingCamera = true
            }
            
            Button("Galería") {
                showingImagePicker = true
            }
            
            if selectedImage != nil {
                Button("Eliminar imagen", role: .destructive) {
                    selectedImage = nil
                }
            }
            
            Button("Cancelar", role: .cancel) { }
        }
        .sheet(isPresented: $showingCamera) {
            CameraImagePicker(selectedImage: $selectedImage)
        }
        .sheet(isPresented: $showingImagePicker) {
            PhotoLibraryImagePicker(selectedImages: .constant([]), maxImages: 1)
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: AppDimensions.spacingXL) {
        ImagePickerView(
            selectedImages: .constant([]),
            maxImages: 5,
            title: "Fotos del producto"
        )
        
        SingleImagePicker(
            selectedImage: .constant(nil),
            placeholder: "Agregar foto de perfil"
        )
        
        Spacer()
    }
    .padding()
}