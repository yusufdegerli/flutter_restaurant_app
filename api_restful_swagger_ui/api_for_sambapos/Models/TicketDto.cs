using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace api_for_sambapos.Models
{
    public class TicketDto
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public string Name { get; set; } = "No Name";

        [Required]
        public int DepartmentId { get; set; }
        [Required]
        public DateTime LastUpdateTime { get; set; }
        [Required]
        public string TicketNumber { get; set; } = "No Number";

        [Column(TypeName = "nvarchar(max)")]
        [Required]
        public string? PrintJobData { get; set; }
        [Required]
        public DateTime Date { get; set; }
        [Required]
        public DateTime LastOrderDate { get; set; }
        [Required]
        public DateTime? LastPaymentDate { get; set; }

        public string LocationName { get; set; } = "No Location";
        public int CustomerId { get; set; }
        public string CustomerName { get; set; } = "No Customer";
        public string? CustomerGroupCode { get; set; } // Nullable yapıldı
        [Required]
        public bool IsPaid { get; set; }

        [Column(TypeName = "decimal(18, 2)")]
        public decimal RemainingAmount { get; set; }

        [Column(TypeName = "decimal(18, 2)")]
        [Required]
        public decimal TotalAmount { get; set; }
        public string Note { get; set; } = "No Notes";
        [Required]
        public bool Locked { get; set; }
        public string Tag { get; set; } = "No Tags";
    }
}