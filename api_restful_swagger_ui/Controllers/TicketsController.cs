// Controllers/TicketsController.cs
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using api_for_sambapos.Models;
using System.Collections.Generic;
using System.Threading.Tasks;

[ApiController]
[Route("api/[controller]")]
public class TicketsController : ControllerBase
{
    private readonly AppDbContext _context;

    public TicketsController(AppDbContext context)
    {
        _context = context;
    }

    // Tüm Ticket'larý getir
    [HttpGet]
    public async Task<ActionResult<IEnumerable<TicketDto>>> GetTickets()
    {
        try
        {
            return await _context.Tickets
                .Select(t => new TicketDto
                {
                    Id = t.Id,
                    Name = t.Name != null ? t.Name : "No Name",
                    TicketNumber = t.TicketNumber != null ? t.TicketNumber : "No Number",
                    CustomerName = t.CustomerName != null ? t.CustomerName : "No Customer",
                    RemainingAmount = (double)t.RemainingAmount,
                    TotalAmount = (double)t.TotalAmount,
                    Note = t.Note != null ? t.Note : "No Notes",
                    Tag = t.Tag != null ? t.Tag : "No Tags"
                })
                .ToListAsync();
        }
        catch (System.Data.SqlTypes.SqlNullValueException ex)
        {
            return StatusCode(500, "Veritabanýnda null deðerler bulundu: " + ex.Message);
        }
    }

    // Id'ye göre tek Ticket getir
    [HttpGet("{id}")]
    public async Task<ActionResult<TicketDto>> GetTicket(int id)
    {
        try
        {
            var ticket = await _context.Tickets.FindAsync(id);
            if (ticket == null) return NotFound();

            return new TicketDto
            {
                Id = ticket.Id,
                Name = ticket.Name != null ? ticket.Name : "Ýsmi yok",
                TicketNumber = ticket.TicketNumber != null ? ticket.TicketNumber : "No Number",
                CustomerName = ticket.CustomerName != null ? ticket.CustomerName : "No Customer",
                RemainingAmount = (double)ticket.RemainingAmount,
                TotalAmount = (double)ticket.TotalAmount,
                Note = ticket.Note != null ? ticket.Note : "No Notes",
                Tag = ticket.Tag != null ? ticket.Tag : "No Tags"
            };
        }
        catch (System.Data.SqlTypes.SqlNullValueException ex)
        {
            return StatusCode(500, "Veritabanýnda null deðerler bulundu: " + ex.Message);
        }
    }


    [HttpPost]
    public async Task<ActionResult<Ticket>> PostTicket(TicketDto ticketDto)
    {
        try
        {
            // Model doðrulamasý
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            // Ticket nesnesi oluþtur
            var ticket = new Ticket
            {
                Date = ticketDto.Date,
                LastUpdateTime = ticketDto.LastUpdateTime,
                TicketNumber = ticketDto.TicketNumber ?? "No Number",
                DepartmentId = ticketDto.DepartmentId,
                LocationName = ticketDto.LocationName ?? "No Location",
                CustomerId = ticketDto.CustomerId,
                CustomerName = ticketDto.CustomerName ?? "No Customer",
                Note = ticketDto.Note ?? "No Notes",
                IsPaid = ticketDto.IsPaid,
                TotalAmount = (decimal)ticketDto.TotalAmount,
                RemainingAmount = (decimal)ticketDto.RemainingAmount,
                // Diðer varsayýlan deðerler
                Name = "No Name", // Örnek: Ýstemciden gelmiyorsa
                Locked = false    // Varsayýlan deðer
            };

            // Veritabanýna ekle
            _context.Tickets.Add(ticket);
            await _context.SaveChangesAsync();

            // 201 Created yanýtý dön
            return CreatedAtAction(nameof(GetTicket), new { id = ticket.Id }, ticket);
        }
        catch (Exception ex)
        {
            return StatusCode(500, "Internal server error: " + ex.Message);
        }
    }
}