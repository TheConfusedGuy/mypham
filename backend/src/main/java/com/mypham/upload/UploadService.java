package com.mypham.upload;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import com.mypham.common.exception.BusinessException;
import com.mypham.common.exception.ErrorCode;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Map;
import java.util.Set;

@Slf4j
@Service
@RequiredArgsConstructor
public class UploadService {

    private final Cloudinary cloudinary;

    @Value("${app.uploads.dir:uploads}")
    private String uploadsDir;

    private static final Set<String> ALLOWED_TYPES = Set.of(
            "image/jpeg", "image/png", "image/webp"
    );

    public UploadResponse store(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new BusinessException(ErrorCode.VALIDATION_FAILED, "File rỗng");
        }
        String claimedType = file.getContentType();
        if (claimedType == null || !ALLOWED_TYPES.contains(claimedType)) {
            throw new BusinessException(ErrorCode.VALIDATION_FAILED,
                    "Chỉ chấp nhận JPEG/PNG/WEBP");
        }

        try {
            byte[] bytes = file.getBytes();
            String detectedType = detectImageType(bytes);
            if (detectedType == null) {
                throw new BusinessException(ErrorCode.VALIDATION_FAILED,
                        "Nội dung file không phải ảnh JPEG/PNG/WEBP");
            }
            if (!detectedType.equals(claimedType)) {
                throw new BusinessException(ErrorCode.VALIDATION_FAILED,
                        "Định dạng file không khớp: header=" + claimedType + " nhưng nội dung=" + detectedType);
            }

            // Tải ảnh lên Cloudinary
            Map<?, ?> uploadResult = cloudinary.uploader().upload(bytes, ObjectUtils.asMap(
                    "folder", "mypham",
                    "resource_type", "image"
            ));

            String url = (String) uploadResult.get("secure_url");
            String filename = (String) uploadResult.get("public_id");

            log.info("Uploaded to Cloudinary: {} -> {} (type: {})", file.getOriginalFilename(), url, detectedType);
            return new UploadResponse(url, filename, file.getSize());
        } catch (IOException e) {
            throw new BusinessException(ErrorCode.INTERNAL_ERROR,
                    "Lỗi upload Cloudinary: " + e.getMessage());
        }
    }

    private static String detectImageType(byte[] data) {
        if (data == null || data.length < 12) return null;

        if ((data[0] & 0xFF) == 0xFF && (data[1] & 0xFF) == 0xD8 && (data[2] & 0xFF) == 0xFF) {
            return "image/jpeg";
        }

        if ((data[0] & 0xFF) == 0x89 && data[1] == 'P' && data[2] == 'N' && data[3] == 'G'
                && data[4] == 0x0D && data[5] == 0x0A && data[6] == 0x1A && data[7] == 0x0A) {
            return "image/png";
        }

        if (data[0] == 'R' && data[1] == 'I' && data[2] == 'F' && data[3] == 'F'
                && data[8] == 'W' && data[9] == 'E' && data[10] == 'B' && data[11] == 'P') {
            return "image/webp";
        }
        return null;
    }

    public void deleteByUrl(String url) {
        if (url == null || url.isBlank()) return;

        if (url.contains("res.cloudinary.com")) {
            try {
                // Trích xuất publicId từ Cloudinary URL (ví dụ: https://res.cloudinary.com/.../mypham/filename.jpg)
                int idx = url.indexOf("image/upload/");
                if (idx != -1) {
                    String path = url.substring(idx + "image/upload/".length());
                    // Loại bỏ tiền tố phiên bản nếu có (ví dụ: v12345678/mypham/filename.jpg)
                    if (path.startsWith("v")) {
                        int slashIdx = path.indexOf("/");
                        if (slashIdx != -1) {
                            path = path.substring(slashIdx + 1);
                        }
                    }
                    // Loại bỏ phần mở rộng rộng đuôi file
                    int dotIdx = path.lastIndexOf(".");
                    String publicId = (dotIdx != -1) ? path.substring(0, dotIdx) : path;

                    log.info("Deleting image from Cloudinary with public ID: {}", publicId);
                    cloudinary.uploader().destroy(publicId, ObjectUtils.emptyMap());
                }
            } catch (Exception e) {
                log.warn("Lỗi xoá file trên Cloudinary {}: {}", url, e.getMessage());
            }
        } else {
            // Giữ lại logic xoá file local cũ để tương thích ngược với các ảnh seed đã lưu trong Git
            if (!url.startsWith("/uploads/")) return;
            String filename = url.substring("/uploads/".length());
            if (filename.isBlank() || filename.contains("/") || filename.contains("..")) {
                log.warn("Skip suspicious filename: {}", filename);
                return;
            }
            try {
                Path target = Paths.get(uploadsDir).toAbsolutePath().resolve(filename);
                boolean deleted = Files.deleteIfExists(target);
                log.info("Delete file local {}: {}", target, deleted ? "ok" : "not found");
            } catch (IOException e) {
                log.warn("Lỗi xoá file local {}: {}", url, e.getMessage());
            }
        }
    }
}
