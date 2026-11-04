import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  static Route<ContactUsScreen> route(final RouteSettings routeSettings) =>
      CupertinoPageRoute(
        builder: (final _) => BlocProvider(
          create: (context) => SendQueryToAdminCubit(),
          child: const ContactUsScreen(),
        ),
      );

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  late Map<String, dynamic> contactUsDetails = context
      .read<SystemSettingCubit>()
      .getSupportDetails;
  late List<SocialMediaURL> socialMediaLinks =
      context.read<SystemSettingCubit>().socialMediaLinks ?? [];

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _nameTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _subjectTextController = TextEditingController();
  TextEditingController _messageTextController = TextEditingController();

  FocusNode _emailFocusNode = FocusNode();
  FocusNode _subjectFocusNode = FocusNode();
  FocusNode _messageFocusNode = FocusNode();

  bool _isAcceptedTerms = false;

  @override
  Widget build(BuildContext context) {
    return AnnotatedSafeArea(
      isAnnotated: true,
      applyBottomInset: false,
      child: Scaffold(
        backgroundColor: context.colors.backgroundSecondary,
        appBar: UiUtils.getSimpleAppBar(
          context: context,
          title: "contactUs".translate(context: context),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(
            16,
          ).copyWith(bottom: 16 + MediaQuery.viewPaddingOf(context).bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (contactUsDetails.isNotEmpty) ...[
                _buildContactInfoCard(),
                const CustomSizedBox(height: 16),
              ],
              _buildCard(
                child: CustomInkWellContainer(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      chatMessages,
                      arguments: {
                        "chatUser": ChatUser(
                          id: "0",
                          name: "customerSupport",
                          translatedName: "customerSupport",
                          chatUserType: ChatUserType.adminSupport,
                          unReadChats: 0,
                          partnerId: null,
                        ),
                      },
                    );
                  },
                  child: _buildInfoRow(
                    icon: AppAssets.support,
                    label: "chatWithUs".translate(context: context),
                    value: "chatWithUsDescription".translate(context: context),
                  ),
                ),
              ),
              if (socialMediaLinks.isNotEmpty) ...[
                const CustomSizedBox(height: 16),
                _buildSocialMediaLinkWidget(),
              ],
              const CustomSizedBox(height: 16),
              _buildCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLetsTalkTitleWidget(),
                      const CustomSizedBox(height: 4),
                      _buildLetsTalkSubTitleWidget(),
                      const CustomSizedBox(height: 12),
                      _buildNameTextFieldWidget(),
                      const CustomSizedBox(height: 12),
                      _buildEmailTextFieldWidget(),
                      const CustomSizedBox(height: 12),
                      _buildSubjectTextFieldWidget(),
                      const CustomSizedBox(height: 12),
                      _buildMessageTextFieldWidget(),
                      _buildTermsAndConditionCheckbox(),
                      const CustomSizedBox(height: 4),
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
              const CustomSizedBox(height: 16),
              _buildFAQsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required final Widget child}) => CustomContainer(
    width: double.infinity,
    color: context.colors.surfacePrimary,
    borderRadius: UiUtils.borderRadiusOf12,
    padding: const EdgeInsets.all(12),
    child: child,
  );

  Widget _buildIconContainer(final String icon) => CustomContainer(
    color: context.colors.backgroundSecondary,
    borderRadius: 24,
    padding: const EdgeInsets.all(8),
    child: CustomSvgPicture(
      avoideResponsive: true,
      svgImage: icon,
      color: context.colors.iconPrimary,
      height: 20,
      width: 20,
    ),
  );

  Widget _buildInfoRow({
    required final String icon,
    required final String label,
    required final String value,
  }) => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      _buildIconContainer(icon),
      const CustomSizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              label,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: context.colors.textSecondary,
            ),
            const CustomSizedBox(height: 4),
            CustomText(
              value,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: context.colors.textPrimary,
            ),
          ],
        ),
      ),
    ],
  );

  Widget _buildContactInfoCard() {
    final List<Widget> rows = [];

    void addRow(final Widget row) {
      if (rows.isNotEmpty) {
        rows.add(const CustomSizedBox(height: 12));
        rows.add(
          CustomSizedBox(
            height: 1,
            width: double.infinity,
            child: DashedRect(
              color: context.colors.borderDefault,
              strokeWidth: 1,
              gap: 4,
            ),
          ),
        );
        rows.add(const CustomSizedBox(height: 12));
      }
      rows.add(row);
    }

    if ((contactUsDetails["email"] ?? '') != '') {
      addRow(
        CustomInkWellContainer(
          onTap: () async {
            try {
              if (await canLaunchUrl(
                Uri.parse("mailto:${contactUsDetails["email"]}"),
              )) {
                launchUrl(
                  Uri.parse("mailto:${contactUsDetails["email"]}"),
                  mode: LaunchMode.externalApplication,
                );
              } else {
                throw Exception();
              }
            } catch (e) {
              if (!mounted) return;
              UiUtils.showMessage(
                context,
                'unableToOpen'.translate(context: context),
                ToastificationType.error,
              );
            }
          },
          child: _buildInfoRow(
            icon: AppAssets.envelopeSimple,
            label: "email".translate(context: context),
            value: contactUsDetails["email"],
          ),
        ),
      );
    }
    if ((contactUsDetails["mobile"] ?? '') != '') {
      addRow(
        CustomInkWellContainer(
          onTap: () async {
            try {
              if (await canLaunchUrl(
                Uri.parse("tel:${contactUsDetails["mobile"]}"),
              )) {
                launchUrl(
                  Uri.parse("tel:${contactUsDetails["mobile"]}"),
                  mode: LaunchMode.externalApplication,
                );
              } else {
                throw Exception();
              }
            } catch (e) {
              if (!mounted) return;
              UiUtils.showMessage(
                context,
                'unableToOpen'.translate(context: context),
                ToastificationType.error,
              );
            }
          },
          child: _buildInfoRow(
            icon: AppAssets.phoneCall,
            label: "phone".translate(context: context),
            value: contactUsDetails["mobile"],
          ),
        ),
      );
    }
    if ((contactUsDetails["address"] ?? '') != '') {
      addRow(
        _buildInfoRow(
          icon: AppAssets.mapPinArea,
          label: "location".translate(context: context),
          value: contactUsDetails["address"],
        ),
      );
    }
    if ((contactUsDetails["supportHours"] ?? '') != '') {
      addRow(
        _buildInfoRow(
          icon: AppAssets.clock,
          label: "supportHours".translate(context: context),
          value: contactUsDetails["supportHours"],
        ),
      );
    }

    if (rows.isEmpty) return const SizedBox.shrink();

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows,
      ),
    );
  }

  Widget _buildSocialMediaLinkWidget() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            "ourSocials".translate(context: context),
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: context.colors.textPrimary,
          ),
          const CustomSizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(
              socialMediaLinks.length,
              (index) => CustomInkWellContainer(
                borderRadius: BorderRadius.circular(24),
                onTap: () async {
                  try {
                    if (await canLaunchUrl(
                      Uri.parse(socialMediaLinks[index].url ?? ''),
                    )) {
                      launchUrl(
                        Uri.parse(socialMediaLinks[index].url ?? ''),
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      throw Exception();
                    }
                  } catch (e) {
                    if (!mounted) return;
                    UiUtils.showMessage(
                      context,
                      'unableToOpen'.translate(context: context),
                      ToastificationType.error,
                    );
                  }
                },
                child: CustomContainer(
                  color: context.colors.backgroundSecondary,
                  shape: BoxShape.circle,
                  padding: const EdgeInsets.all(8),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      context.colors.iconPrimary,
                      BlendMode.srcIn,
                    ),
                    child: CustomCachedNetworkImage(
                      networkImageUrl: socialMediaLinks[index].imageURL ?? '',
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQsSection() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 4),
      child: Text.rich(
        TextSpan(
          text:
              "${"youMightAlsoFindYourAnswersOn".translate(context: context)} ",
          style: TextStyle(color: context.colors.textSecondary, fontSize: 12),
          children: [
            TextSpan(
              text: "faqs".translate(context: context),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.pushNamed(context, faqsRoute);
                },
              style: TextStyle(
                color: context.colors.textBrand,
                fontSize: 12,
                decoration: TextDecoration.underline,
                decorationColor: context.colors.textBrand,
              ),
            ),
            TextSpan(
              text:
                  " ${"ifYouHaventCheckedItAlreadyBeforeContactingUs".translate(context: context)}",
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLetsTalkTitleWidget() {
    return CustomText(
      "letsTalk".translate(context: context),
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: context.colors.textPrimary,
    );
  }

  Widget _buildLetsTalkSubTitleWidget() {
    return CustomText(
      "weLoveYourFeedbackSuggestionAndReviewOnHowToServeYou".translate(
        context: context,
      ),
      color: context.colors.textSecondary,
      fontSize: 12,
    );
  }

  Widget _buildNameTextFieldWidget() {
    return CustomTextFormField(
      controller: _nameTextController,
      labelText: "name".translate(context: context),
      hintText: "name".translate(context: context),
      isRequired: true,
      fillColor: context.colors.backgroundSecondary,
      borderColor: context.colors.borderDefault,
      focusedBorderColor: context.colors.borderFocus,
      bottomPadding: 0,
      nextFocusNode: _emailFocusNode,
      validator: (name) => isTextFieldEmpty(value: name, context: context),
    );
  }

  Widget _buildEmailTextFieldWidget() {
    return CustomTextFormField(
      controller: _emailTextController,
      labelText: "email".translate(context: context),
      hintText: "email".translate(context: context),
      isRequired: true,
      fillColor: context.colors.backgroundSecondary,
      borderColor: context.colors.borderDefault,
      focusedBorderColor: context.colors.borderFocus,
      bottomPadding: 0,
      currentFocusNode: _emailFocusNode,
      validator: (email) => isValidEmail(email: email ?? '', context: context),
      nextFocusNode: _subjectFocusNode,
    );
  }

  Widget _buildSubjectTextFieldWidget() {
    return CustomTextFormField(
      controller: _subjectTextController,
      labelText: "subject".translate(context: context),
      hintText: "subject".translate(context: context),
      isRequired: true,
      fillColor: context.colors.backgroundSecondary,
      borderColor: context.colors.borderDefault,
      focusedBorderColor: context.colors.borderFocus,
      bottomPadding: 0,
      currentFocusNode: _subjectFocusNode,
      validator: (subject) =>
          isTextFieldEmpty(value: subject, context: context),
      nextFocusNode: _messageFocusNode,
    );
  }

  Widget _buildMessageTextFieldWidget() {
    return CustomTextFormField(
      controller: _messageTextController,
      labelText: "message".translate(context: context),
      hintText: "message".translate(context: context),
      isRequired: true,
      fillColor: context.colors.backgroundSecondary,
      borderColor: context.colors.borderDefault,
      focusedBorderColor: context.colors.borderFocus,
      bottomPadding: 0,
      expands: true,
      textInputType: TextInputType.multiline,
      currentFocusNode: _messageFocusNode,
      minLines: 2,
      validator: (message) =>
          isTextFieldEmpty(value: message, context: context),
      textInputAction: TextInputAction.done,
    );
  }

  @override
  void dispose() {
    _nameTextController.dispose();
    _emailTextController.dispose();
    _messageTextController.dispose();
    _subjectTextController.dispose();

    _emailFocusNode.dispose();
    _subjectFocusNode.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  Widget _buildTermsAndConditionCheckbox() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CustomInkWellContainer(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              setState(() {
                _isAcceptedTerms = !_isAcceptedTerms;
              });
            },
            child: CustomContainer(
              width: 20,
              height: 20,
              shape: BoxShape.circle,
              color: _isAcceptedTerms
                  ? context.colors.component.buttonPrimaryBg
                  : Colors.transparent,
              border: _isAcceptedTerms
                  ? null
                  : Border.all(color: context.colors.iconPrimary, width: 1.5),
              child: _isAcceptedTerms
                  ? Icon(
                      Icons.check,
                      size: 14,
                      color: context.colors.component.buttonPrimaryText,
                    )
                  : null,
            ),
          ),
          const CustomSizedBox(width: 12),
          Expanded(
            child: Text.rich(
              style: const TextStyle(height: 1.6),
              TextSpan(
                text:
                    "${"byRegisteringYouAgreeTo".translate(context: context)} ",
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 12,
                ),
                children: [
                  TextSpan(
                    text: "termsofservice".translate(context: context),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.pushNamed(
                          context,
                          customPageDetailsRoute,
                          arguments: {
                            "title": "termsofservice".translate(
                              context: context,
                            ),
                            "pageKey": "customer_terms_conditions",
                          },
                        );
                      },
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                      decorationColor: context.colors.textPrimary,
                    ),
                  ),
                  TextSpan(
                    text: " & ",
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  TextSpan(
                    text: "privacyAndPolicy".translate(context: context),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.pushNamed(
                          context,
                          customPageDetailsRoute,
                          arguments: {
                            "title": "privacyAndPolicy".translate(
                              context: context,
                            ),
                            "pageKey": "customer_privacy_policy",
                          },
                        );
                      },
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                      decorationColor: context.colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return BlocConsumer<SendQueryToAdminCubit, SendQueryToAdminState>(
      listener: (context, state) {
        UiUtils.removeFocus();
        if (state is SendQueryToAdminFailureState) {
          UiUtils.showMessage(
            context,
            'weCouldntSendYourRequestPleaseTryAgainLater'.translate(
              context: context,
            ),
            ToastificationType.error,
          );
        } else if (state is SendQueryToAdminSuccessState) {
          _nameTextController.clear();
          _emailTextController.clear();
          _subjectTextController.clear();
          _messageTextController.clear();
          _isAcceptedTerms = false;
          setState(() {});
          UiUtils.showMessage(
            context,
            'yourRequestHasBeenSuccessfullySent'.translate(context: context),
            ToastificationType.success,
          );
        }
      },
      builder: (context, state) {
        final bool isLoading = state is SendQueryToAdminInProgressState;
        return CustomRoundedButton(
          buttonTitle: "submit".translate(context: context),
          showBorder: false,
          widthPercentage: 1,
          backgroundColor: _isAcceptedTerms
              ? context.colors.component.buttonPrimaryBg
              : context.colors.backgroundSecondary,
          titleColor: _isAcceptedTerms
              ? context.colors.component.buttonPrimaryText
              : context.colors.textSecondary,
          onTap: () {
            if (!_isAcceptedTerms) {
              return;
            }
            if (state is SendQueryToAdminInProgressState) {
              return;
            }
            if (_formKey.currentState!.validate()) {
              context.read<SendQueryToAdminCubit>().sendQueryToAdmin(
                name: _nameTextController.text.trim().toString(),
                email: _emailTextController.text.trim().toString(),
                subject: _subjectTextController.text.trim().toString(),
                message: _messageTextController.text.trim().toString(),
              );
            }
          },
          child: isLoading
              ? CustomCircularProgressIndicator(
                  color: context.colors.component.buttonPrimaryText,
                )
              : null,
        );
      },
    );
  }
}
