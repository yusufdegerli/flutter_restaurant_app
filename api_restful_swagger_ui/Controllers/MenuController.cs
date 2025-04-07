using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using api_for_sambapos.Models;

[ApiController]
[Route("api/[controller]")]
public class MenuController : ControllerBase
{
    private readonly AppDbContext _context;

    public MenuController(AppDbContext context) => _context = context;

    [HttpGet]
    public async Task<ActionResult<IEnumerable<MenuItem>>> GetMenuItems()
    {
        return await _context.MenuItems
            .Select(m => new MenuItem
            {
                Id = m.Id,
                Name = m.Name ?? string.Empty,
                GroupCode = m.GroupCode ?? string.Empty,
                Price = 0,
                Category = m.GroupCode ?? "Main"
            })
            .ToListAsync();
    }

    [HttpGet("by-category/{category}")]
    public async Task<ActionResult<IEnumerable<MenuItem>>> GetMenuItemsByCategory(string category)
    {
        return await _context.MenuItems
            .Where(m => m.GroupCode == category)
            .Select(m => new MenuItem
            {
                Id = m.Id,
                Name = m.Name ?? string.Empty,
                GroupCode = m.GroupCode ?? string.Empty,
                Price = 0,
                Category = m.GroupCode ?? "Main"
            })
            .ToListAsync();
    }
}