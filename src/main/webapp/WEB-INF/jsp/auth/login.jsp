<%@ page contentType="text/html;charset=UTF-8" %>

<h2>Login</h2>

<form method="post" action="/login">
    <input type="text" name="username" placeholder="Username"/><br/>
    <input type="password" name="password" placeholder="Password"/><br/>
    <button type="submit">Login</button>
</form>

<a href="/auth/register">Register</a>