using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace api_for_sambapos.Models
{
    public class Ticket
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public string Name { get; set; } = "No Name";

        public int DepartmentId { get; set; }

        public DateTime LastUpdateTime { get; set; }

        public string TicketNumber { get; set; } = "No Number";

        [Column(TypeName = "nvarchar(max)")]
        public string? PrintJobData { get; set; }

        public DateTime Date { get; set; }

        public DateTime? LastTableDate { get; set; }

        public DateTime? LastPaymentDate { get; set; }

        public string LocationName { get; set; } = "No Location";

        public int CustomerId { get; set; }

        public string CustomerName { get; set; } = "No Customer";

        public bool IsPaid { get; set; }

        [Column(TypeName = "decimal(18, 2)")]
        public decimal RemainingAmount { get; set; }

        [Column(TypeName = "decimal(18, 2)")]
        public decimal TotalAmount { get; set; }

        public string Note { get; set; } = "No Notes";

        public bool Locked { get; set; }

        public string Tag { get; set; } = "No Tags";
    }
}