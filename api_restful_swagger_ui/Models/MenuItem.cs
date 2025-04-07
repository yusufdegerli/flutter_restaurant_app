using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace api_for_sambapos.Models
{
    public class MenuItem
    {
        public int Id { get; set; }

        [Required]
        public string? Name { get; set; } = string.Empty;

        [Column("GroupCode")]
        public string? GroupCode { get; set; } = string.Empty;

        // Price ve Category veritabanında yoksa [NotMapped] ekleyin
        [NotMapped]
        public decimal Price { get; set; }

        [NotMapped]
        public string Category { get; set; } = "Main";
    }
}