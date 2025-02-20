import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../helpers/app_regex.dart';
import '../../../routing/routes.dart';
import '../../../theming/styles.dart';
import '../../helpers/extensions.dart';
import '../../helpers/rive_controller.dart';
import '../../logic/cubit/auth_cubit.dart';
import 'app_text_button.dart';
import 'app_text_form_field.dart';
import 'password_validations.dart';

// ignore: must_be_immutable
class EmailAndPassword extends StatefulWidget {
  final bool? isSignUpPage;
  final bool? isPasswordPage;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  const EmailAndPassword({
    super.key,
    this.isSignUpPage,
    this.isPasswordPage,
    this.email,
    this.displayName,
    this.photoUrl,
  });

  @override
  State<EmailAndPassword> createState() => _EmailAndPasswordState();
}

class _EmailAndPasswordState extends State<EmailAndPassword> {
  bool isObscureText = true;
  bool hasMinLength = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmationController =
      TextEditingController();

  final formKey = GlobalKey<FormState>();

  final RiveAnimationControllerHelper riveHelper =
      RiveAnimationControllerHelper();

  final passwordFocuseNode = FocusNode();
  final passwordConfirmationFocuseNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.email != null) {
      emailController.text = widget.email!;
    }
    if (widget.displayName != null) {
      nameController.text = widget.displayName!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 5,
            child: riveHelper.currentWidget ??
                Image.asset('assets/animation/icon.PNG'),
          ),
          if (widget.isSignUpPage ?? false) nameField(),
          emailField(),
          passwordField(),
          Gap(18.h),
          if (widget.isSignUpPage ?? false) passwordConfirmationField(),
          forgetPasswordTextButton(),
          Gap(10.h),
          PasswordValidations(
            hasMinLength: hasMinLength,
          ),
          Gap(20.h),
          loginOrSignUpOrPasswordButton(context),
        ],
      ),
    );
  }

  void checkForPasswordConfirmationFocused() {
    passwordConfirmationFocuseNode.addListener(() {
      if (passwordConfirmationFocuseNode.hasFocus && isObscureText) {
        riveHelper.addHandsUpController();
      } else if (!passwordConfirmationFocuseNode.hasFocus && isObscureText) {
        riveHelper.addHandsDownController();
      }
    });
  }

  void checkForPasswordFocused() {
    passwordFocuseNode.addListener(() {
      if (passwordFocuseNode.hasFocus && isObscureText) {
        riveHelper.addHandsUpController();
      } else if (!passwordFocuseNode.hasFocus && isObscureText) {
        riveHelper.addHandsDownController();
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordConfirmationController.dispose();
    passwordFocuseNode.dispose();
    passwordConfirmationFocuseNode.dispose();
    super.dispose();
  }

  Widget loginOrSignUpOrPasswordButton(BuildContext context) {
    return AppTextButton(
      buttonText: widget.isPasswordPage ?? false
          ? 'Create Password'
          : widget.isSignUpPage ?? false
              ? 'Sign Up'
              : 'Login',
      textStyle: TextStyles.font16White600Weight,
      onPressed: () {
        if (formKey.currentState!.validate()) {
          if (widget.isPasswordPage ?? false) {
            context.read<AuthCubit>().createAccountWithGoogleData(
                  widget.email!,
                  passwordController.text,
                  widget.displayName,
                  widget.photoUrl,
                );
          } else if (widget.isSignUpPage ?? false) {
            context.read<AuthCubit>().signUpWithEmail(
                  emailController.text,
                  passwordController.text,
                  name: nameController.text,
                );
          } else {
            context.read<AuthCubit>().signInWithEmail(
                  emailController.text,
                  passwordController.text,
                );
          }
        }
      },
    );
  }

  Widget forgetPasswordTextButton() {
    if (!(widget.isSignUpPage ?? false) && !(widget.isPasswordPage ?? false)) {
      return Align(
        alignment: AlignmentDirectional.centerEnd,
        child: TextButton(
          onPressed: () => context.pushNamed(Routes.forgetScreen),
          child: Text(
            'Forget Password?',
            style: TextStyles.font14Blue400Weight,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget nameField() {
    if (widget.isSignUpPage ?? false) {
      return Column(
        children: [
          AppTextFormField(
            controller: nameController,
            hint: 'Name',
            validator: (value) {
              if ((value ?? '').isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          Gap(18.h),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget emailField() {
    return Column(
      children: [
        AppTextFormField(
          controller: emailController,
          hint: 'Email',
          onChanged: widget.email != null ? null : (value) {},
          validator: (value) {
            if ((value ?? '').isEmpty) {
              return 'Please enter your email';
            }
            if (!AppRegex.isEmailValid(value ?? '')) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        Gap(18.h),
      ],
    );
  }

  Widget passwordField() {
    return AppTextFormField(
      controller: passwordController,
      hint: 'Password',
      isObscureText: isObscureText,
      suffixIcon: IconButton(
        icon: Icon(
          isObscureText ? Icons.visibility_off : Icons.visibility,
        ),
        onPressed: () {
          setState(() {
            isObscureText = !isObscureText;
          });
          if (passwordFocuseNode.hasFocus) {
            if (isObscureText) {
              riveHelper.addHandsUpController();
            } else {
              riveHelper.addHandsDownController();
            }
          }
        },
      ),
      focusNode: passwordFocuseNode,
      validator: (value) {
        if ((value ?? '').isEmpty) {
          return 'Please enter your password';
        }
        if ((value ?? '').length < 8) {
          return 'Password must be at least 8 characters';
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          hasMinLength = (value).length >= 8;
        });
      },
    );
  }

  Widget passwordConfirmationField() {
    if (widget.isSignUpPage ?? false) {
      return AppTextFormField(
        controller: passwordConfirmationController,
        hint: 'Password Confirmation',
        isObscureText: isObscureText,
        focusNode: passwordConfirmationFocuseNode,
        validator: (value) {
          if ((value ?? '').isEmpty) {
            return 'Please confirm your password';
          }
          if (value != passwordController.text) {
            return 'Passwords do not match';
          }
          return null;
        },
      );
    }
    return const SizedBox.shrink();
  }
}
