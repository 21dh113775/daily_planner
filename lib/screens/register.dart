import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:email_validator/email_validator.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:password_strength/password_strength.dart';
import '../database/dataHelper.dart'; // Import the DatabaseHelper

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  double _passwordStrength = 0;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Check password strength
  void _checkPasswordStrength(String password) {
    setState(() {
      _passwordStrength = estimatePasswordStrength(password);
    });
  }

  // Form submission logic
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      // Initialize DatabaseHelper and check if the user exists
      DatabaseHelper dbHelper = DatabaseHelper();
      var existingUser = await dbHelper.getUserByEmail(email);

      if (existingUser != null) {
        _showAwesomeSnackBar('Lỗi', 'Email đã tồn tại.', ContentType.failure);
      } else {
        await dbHelper.insertUser(email, password);
        _showAwesomeSnackBar(
            'Thành công', 'Đăng ký thành công!', ContentType.success);

        // Navigate to the login screen
        _navigateToLogin();
      }
    }
  }

  // AwesomeSnackbar for notifications
  void _showAwesomeSnackBar(
      String title, String message, ContentType contentType) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: contentType,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  // Navigate to login screen with loading animation
  void _navigateToLogin() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        Future.delayed(Duration(seconds: 2), () {
          Navigator.of(context).pop(); // Close loading dialog
          Navigator.pushReplacementNamed(
              context, '/login'); // Navigate to login page
        });

        return Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
            color: const Color.fromARGB(255, 70, 214, 240),
            size: 60,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/oclock_gif.gif',
                    height: 150,
                  ),
                  SizedBox(height: 30),
                  Center(
                    child: Text(
                      'Đăng Ký',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  // Email Input Field
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email Sinh Viên',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập email';
                      }
                      if (!EmailValidator.validate(value)) {
                        return 'Vui lòng nhập email hợp lệ';
                      }
                      if (!value.endsWith('@st.huflit.edu.vn')) {
                        return 'Ứng dụng chưa hỗ trợ, yêu cầu nhập lại đúng mail sinh viên';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  // Password Input Field
                  TextFormField(
                    controller: _passwordController,
                    onChanged: _checkPasswordStrength,
                    decoration: InputDecoration(
                      labelText: 'Mật Khẩu',
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    obscureText: !_isPasswordVisible,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu';
                      }
                      if (value.length < 6 ||
                          !RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value) ||
                          !RegExp(r'[0-9]').hasMatch(value)) {
                        return 'Mật khẩu phải có ít nhất 6 ký tự, chứa số và ký tự đặc biệt';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  // Password Strength Indicator
                  LinearProgressIndicator(
                    value: _passwordStrength,
                    backgroundColor: Colors.grey[300],
                    color: _passwordStrength < 0.3
                        ? Colors.red
                        : _passwordStrength < 0.7
                            ? Colors.yellow
                            : Colors.green,
                    minHeight: 5,
                  ),
                  SizedBox(height: 20),
                  // Confirm Password Input Field
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Xác Nhận Mật Khẩu',
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    obscureText: !_isConfirmPasswordVisible,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng xác nhận mật khẩu';
                      }
                      if (value != _passwordController.text) {
                        return 'Mật khẩu không khớp';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 30),
                  // Registration Button
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent,
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Đăng Ký',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Navigate to Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Đã có tài khoản? '),
                      TextButton(
                        onPressed: _navigateToLogin,
                        style: ElevatedButton.styleFrom(
                          foregroundColor:
                              const Color.fromARGB(255, 31, 164, 204),
                          elevation: 0,
                        ),
                        child: Text('Đăng nhập'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
