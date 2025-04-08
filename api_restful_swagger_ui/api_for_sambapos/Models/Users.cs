using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace api_for_sambapos.Models
{
    public class User
    {
        public int Id { get; set; }

        [Required]
        public string Name { get; set; } = string.Empty;

        public string PinCode { get; set; } = string.Empty;

        public int UserRole_Id { get; set; }
        public byte[]? LastUpdateTime { get; set; }
    }
}