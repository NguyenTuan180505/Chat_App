<%@ page contentType="text/html;charset=UTF-8" %>

<h2>Register</h2>

<form method="post" action="/auth/register">
    <input type="text" name="username" placeholder="Username"/><br/>
    <input type="password" name="password" placeholder="Password"/><br/>
    <input type="text" name="fullName" placeholder="Full Name"/><br/>
    <input type="text" name="phone" placeholder="Phone"/><br/>

    <button type="submit">Register</button>
</form>

<a href="/auth/login">Login</a>