<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - ChatApp</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
        }
        .card {
            border: none;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
        }
        .form-control {
            border-radius: 10px;
        }
    </style>
</head>
<body class="d-flex align-items-center">
<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-5 col-lg-4">
            <div class="card p-4">
                <div class="text-center mb-4">
                    <i class="fas fa-comments fa-3x text-primary"></i>
                    <h2 class="mt-3">Welcome Back</h2>
                    <p class="text-muted">Đăng nhập để tiếp tục chat</p>
                </div>

                <form id="loginForm">
                    <div class="mb-3">
                        <label class="form-label">Username</label>
                        <input type="text" name="username" id="username"
                               class="form-control" placeholder="Nhập username" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Mật khẩu</label>
                        <input type="password" name="password" id="password"
                               class="form-control" placeholder="Nhập mật khẩu" required>
                    </div>

                    <div id="errorMsg" class="alert alert-danger d-none"></div>

                    <button type="submit" id="btnLogin" class="btn btn-primary w-100 py-2">
                        <span class="spinner-border spinner-border-sm d-none me-2" id="loading"></span>
                        Đăng nhập
                    </button>
                </form>

                <div class="text-center mt-3">
                    <a href="/auth/register" class="text-decoration-none">Chưa có tài khoản? Đăng ký</a>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.getElementById('loginForm').addEventListener('submit', async function(e) {
        e.preventDefault();

        const btn = document.getElementById('btnLogin');
        const loading = document.getElementById('loading');
        const errorMsg = document.getElementById('errorMsg');

        // Reset UI
        btn.disabled = true;
        loading.classList.remove('d-none');
        errorMsg.classList.add('d-none');

        const formData = new FormData(this);

        try {
            const response = await fetch('/auth/login', {
                method: 'POST',
                body: formData,
                headers: {
                    'X-Requested-With': 'XMLHttpRequest'
                }
            });

            // Đọc JSON dù server trả về status 200 hay 400
            let result;
            try {
                result = await response.json();
            } catch (jsonErr) {
                result = { success: false, message: "Server trả về dữ liệu không hợp lệ" };
            }

            if (result.success === true) {
                // Thành công → chuyển trang
                window.location.href = result.redirect || '/chat';
            } else {
                // Thất bại → hiển thị lỗi
                errorMsg.textContent = result.message || 'Đăng nhập thất bại';
                errorMsg.classList.remove('d-none');
            }
        } catch (err) {
            console.error('Login error:', err);
            errorMsg.textContent = 'Lỗi kết nối với server. Vui lòng thử lại sau!';
            errorMsg.classList.remove('d-none');
        } finally {
            btn.disabled = false;
            loading.classList.add('d-none');
        }
    });
</script>
</body>
</html>