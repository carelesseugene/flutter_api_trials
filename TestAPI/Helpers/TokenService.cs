public static class TokenService
{
    public static string BuildToken(string email, string key, TimeSpan lifetime)
    {
        var claims = new[] { new Claim(ClaimTypes.Email, email) };
        var creds  = new SigningCredentials(
                        new SymmetricSecurityKey(Encoding.UTF8.GetBytes(key)),
                        SecurityAlgorithms.HmacSha256);

        var token = new JwtSecurityToken(
            claims: claims,
            expires: DateTime.UtcNow.Add(lifetime),
            signingCredentials: creds);

        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}
