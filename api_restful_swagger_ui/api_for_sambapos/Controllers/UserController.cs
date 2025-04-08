using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using api_for_sambapos.Models;

[ApiController]
[Route("api/[controller]")]
public class UserController : ControllerBase
{
    private readonly AppDbContext _context;

    public UserController(AppDbContext context) => _context = context;

    [HttpGet]
    public async Task<ActionResult<IEnumerable<User>>> GetUsers()
    {
        return await _context.Users.ToListAsync();
    }

    [HttpGet("by-role/{roleId}")]
    public async Task<ActionResult<IEnumerable<User>>> GetUsersByRole(int roleId)
    {
        return await _context.Users
            .Where(u => u.UserRole_Id == roleId)
            .ToListAsync();
    }
}