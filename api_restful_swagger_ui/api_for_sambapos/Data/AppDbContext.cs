using api_for_sambapos.Models;
using Microsoft.EntityFrameworkCore;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    public DbSet<MenuItem> MenuItems { get; set; }
    public DbSet<Ticket> Tickets { get; set; }
    public DbSet<User> Users { get; set; } // Changed to match the model name
    public DbSet<Tables> Tables { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // Ticket tablosu için tarih alanlarını datetime2 olarak belirtin
        modelBuilder.Entity<Ticket>()
            .Property(t => t.Date)
            .HasColumnType("datetime2");

        modelBuilder.Entity<Ticket>()
            .Property(t => t.LastUpdateTime)
            .HasColumnType("datetime2");

        modelBuilder.Entity<Ticket>()
            .Property(t => t.LastOrderDate)
            .HasColumnType("datetime2");

        modelBuilder.Entity<Ticket>()
            .Property(t => t.LastPaymentDate)
            .HasColumnType("datetime2");

        // Mevcut User konfigürasyonlarınızı koruyun
        modelBuilder.Entity<User>()
            .Ignore(u => u.LastUpdateTime); // MSSQL'de "image" tipi için

        modelBuilder.Entity<User>().ToTable("Users");

        base.OnModelCreating(modelBuilder);
    }
}