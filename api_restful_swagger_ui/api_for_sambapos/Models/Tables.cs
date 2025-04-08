using System.ComponentModel.DataAnnotations;

namespace api_for_sambapos.Models
{
    public class Tables
    {
        public int Id { get; set; }

        [Required]
        public string? Name { get; set; } = string.Empty;
        public int Order { get; set; }
        public string? Category { get; set; } = string.Empty;
    }
}
