// ignore_for_file: must_be_immutable

import 'package:coffein_tracker/helpers/extensions.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/widgets/login_and_signup_animated_form.dart';
import '../../../core/widgets/progress_indicaror.dart';
import '../../../core/widgets/terms_and_conditions_text.dart';
import '../../../logic/cubit/auth_cubit.dart';
import '../../../routing/routes.dart';
import '../../../theming/styles.dart';

class CreatePassword extends StatelessWidget {
  final String email;
  final String? displayName;
  final String? photoUrl;

  CreatePassword({
    super.key,
    required this.email,
    this.displayName,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding:
              EdgeInsets.only(left: 30.w, right: 30.w, bottom: 15.h, top: 5.h),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create Password',
                        style: TextStyles.font24Blue700Weight,
                      ),
                      BlocConsumer<AuthCubit, AuthState>(
                        buildWhen: (previous, current) => previous != current,
                        listenWhen: (previous, current) => previous != current,
                        listener: (context, state) async {
                          if (state is AuthLoading) {
                            ProgressIndicaror.showProgressIndicator(context);
                          } else if (state is AuthError) {
                            await AwesomeDialog(
                              context: context,
                              dialogType: DialogType.error,
                              animType: AnimType.rightSlide,
                              title: 'Error',
                              desc: state.message,
                            ).show();
                          } else if (state is UserSingupAndLinkedWithGoogle) {
                            await AwesomeDialog(
                              context: context,
                              dialogType: DialogType.success,
                              animType: AnimType.rightSlide,
                              title: 'Sign up Success',
                              desc: 'You have successfully signed up.',
                            ).show();
                            await Future.delayed(const Duration(seconds: 2));
                            if (!context.mounted) return;
                            context.pushNamedAndRemoveUntil(
                              Routes.homeScreen,
                              predicate: (route) => false,
                            );
                          }
                        },
                        builder: (context, state) {
                          return EmailAndPassword(
                            isPasswordPage: true,
                            email: email,
                            displayName: displayName,
                            photoUrl: photoUrl,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const TermsAndConditionsText(),
            ],
          ),
        ),
      ),
    );
  }
}
