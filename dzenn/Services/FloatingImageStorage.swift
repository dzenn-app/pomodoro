import Foundation

final class FloatingImageStorage {
    static let shared = FloatingImageStorage()

    private init() {}

    func storeImage(from url: URL) -> String? {
        guard let folder = appSupportImagesFolder() else { return nil }
        let fileExtension = url.pathExtension.isEmpty ? "img" : url.pathExtension
        let fileName = UUID().uuidString + "." + fileExtension
        let destinationURL = folder.appendingPathComponent(fileName)
        do {
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            try FileManager.default.copyItem(at: url, to: destinationURL)
            return destinationURL.path
        } catch {
            return nil
        }
    }

    func removeImage(atPath path: String) {
        guard self.isAppSupportImagePath(path) else { return }
        try? FileManager.default.removeItem(atPath: path)
    }

    private func appSupportImagesFolder() -> URL? {
        guard var folder = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        folder.appendPathComponent("Dzenn", isDirectory: true)
        folder.appendPathComponent("Images", isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            return folder
        } catch {
            return nil
        }
    }

    private func isAppSupportImagePath(_ path: String) -> Bool {
        guard let folder = appSupportImagesFolder() else { return false }
        return path.hasPrefix(folder.path)
    }
}
