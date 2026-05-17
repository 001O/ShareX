using System;
using System.Threading.Tasks;

namespace ShareX.UploadersLib
{
    // Minimal stubs to preserve compilation while removing all upload functionality.

    public enum UploadStatus
    {
        Failed = 0,
        Success = 1
    }

    public class UploadResult
    {
        public UploadStatus Status { get; set; } = UploadStatus.Failed;
        public string Message { get; set; } = "Uploaders removed in ultralight build.";
        public string Url { get; set; } = string.Empty;
    }

    public interface IUploader
    {
        Task<UploadResult> UploadFileAsync(string filePath);
        Task<UploadResult> UploadDataAsync(byte[] data, string fileName);
    }

    public static class UploadService
    {
        // No-op upload methods. Return failed UploadResult immediately.
        public static Task<UploadResult> UploadFileAsync(string filePath)
        {
            return Task.FromResult(new UploadResult { Status = UploadStatus.Failed, Message = "Uploads disabled in ultralight build." });
        }

        public static Task<UploadResult> UploadDataAsync(byte[] data, string fileName)
        {
            return Task.FromResult(new UploadResult { Status = UploadStatus.Failed, Message = "Uploads disabled in ultralight build." });
        }
    }
}
