using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using api_for_sambapos.Models;

[ApiController]
[Route("api/[controller]")]
public class TableController : ControllerBase
{
    private readonly AppDbContext _context;
    
    public TableController(AppDbContext context) => _context = context;

    [HttpGet]
    public async Task<ActionResult<IEnumerable<Tables>>> GetTables()
    {
        return await _context.Tables
            .Select(m => new Tables
            {
                Id = m.Id,
                Name = m.Name ?? string.Empty,
                Order = m.Order,
                Category = m.Category ?? string.Empty
            })
            .ToListAsync();
    }

    [HttpGet("{category}")]
    public async Task<ActionResult<IEnumerable<Tables>>> GetTablesByCategory(string category)
    {
        return await _context.Tables
            .Where(m => m.Category == category)
            .Select(m => new Tables
            {
                Id = m.Id,
                Name = m.Name ?? string.Empty,
                Order = m.Order,
                Category = m.Category ?? string.Empty
            })
            .ToListAsync();
    }
}