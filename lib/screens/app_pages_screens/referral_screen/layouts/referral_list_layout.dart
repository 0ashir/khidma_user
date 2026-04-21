import '../../../../config.dart';

class ReferralListLayout extends StatelessWidget {
  final String name;
  final String email;
  final String status;

  final String? profileImage;

  const ReferralListLayout({
    super.key,
    required this.name,
    required this.email,
    required this.status,
    this.profileImage,
  });

  @override
  Widget build(BuildContext context) {
    bool isPending = status.toLowerCase() == "pending";

    return Container(
      margin: const EdgeInsets.only(bottom: Insets.i12),
      padding: const EdgeInsets.all(Insets.i12),
      decoration: BoxDecoration(
        color: appColor(context).whiteBg,
        borderRadius: BorderRadius.circular(AppRadius.r10),
        border: Border.all(
          color: appColor(context).fieldCardBg,
        ),
      ),
      child: Row(
        children: [
          // Circular Profile Image
          Container(
            height: Sizes.s45,
            width: Sizes.s45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: profileImage != null && profileImage!.isNotEmpty
                    ? NetworkImage(profileImage!) as ImageProvider
                    : AssetImage(eImageAssets.noImageFound3),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const HSpace(Sizes.s12),

          // Name and Email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: appCss.dmDenseBold14
                      .textColor(appColor(context).darkText),
                ),
                const VSpace(Sizes.s4),
                Text(
                  email,
                  style: appCss.dmDenseRegular12
                      .textColor(appColor(context).lightText),
                ),
              ],
            ),
          ),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: Insets.i10, vertical: Insets.i4),
            decoration: BoxDecoration(
              color: isPending
                  ? const Color(0xFFFFF7E6) // Light orange for pending
                  : appColor(context).primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.r20),
            ),
            child: Text(
              status,
              style: appCss.dmDenseMedium12.textColor(
                isPending ? const Color(0xFFFAAD14) : appColor(context).primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
