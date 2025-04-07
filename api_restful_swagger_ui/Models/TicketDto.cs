using System.ComponentModel.DataAnnotations;

namespace api_for_sambapos.Models
{
    // Models/TicketDto.cs
    public class TicketDto
    {
        public int Id { get; set; }
        public DateTime Date { get; set; }
        public DateTime LastUpdateTime { get; set; }
        public string TicketNumber { get; set; } // String
        public int DepartmentId { get; set; }
        public string LocationName { get; set; }
        public int CustomerId { get; set; }
        public string CustomerName { get; set; }
        public string Note { get; set; }
        public bool IsPaid { get; set; }
        public double TotalAmount { get; set; }
        public double RemainingAmount { get; set; }

        // Yeni eklenen zorunlu alanlar:
        public string Tag { get; set; }
        public string Name { get; set; }
        public string CustomersName { get; set; } // Veya CustomerName?
    }
}
