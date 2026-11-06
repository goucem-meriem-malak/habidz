import 'package:flutter/widgets.dart';

const supportedLangs = ['en', 'fr', 'ar'];

const Map<String, Map<String, String>> _m = {
  'en': {
    'appName': 'Habidz', 'tagline': 'Build habits, one square at a time.',
    'login': 'Log in', 'signup': 'Sign up', 'email': 'Email', 'password': 'Password',
    'name': 'Display name', 'forgot': 'Forgot password?', 'resetSent': 'Password reset email sent.',
    'haveAccount': 'Already have an account? Log in', 'noAccount': 'No account? Sign up',
    'verifyBanner': 'Please verify your email.', 'resend': 'Resend', 'sent': 'Email sent.',
    'iVerified': 'I verified', 'profile': 'Profile', 'emptyTitle': 'No habits yet',
    'emptySub': 'Tap + to add your first habit.', 'addHabit': 'New habit', 'editHabit': 'Edit habit',
    'habitName': 'Habit name', 'icon': 'Icon', 'color': 'Color', 'auto': 'Auto',
    'archive': 'Archive (hide)', 'save': 'Save', 'cancel': 'Cancel', 'delete': 'Delete',
    'deleteHabitQ': 'Delete this habit and all its history?', 'streak': 'Streak', 'best': 'Best',
    'offline': 'Offline or syncing - changes are saved on this device.',
    'theme': 'Theme', 'tSystem': 'System', 'tLight': 'Light', 'tDark': 'Dark', 'tPurple': 'Premium purple',
    'language': 'Language', 'changePw': 'Change password', 'currentPw': 'Current password',
    'newPw': 'New password (min 8)', 'pwChanged': 'Password changed.', 'export': 'Export my data',
    'exported': 'Data copied to clipboard as JSON.', 'logout': 'Log out', 'deleteAcc': 'Delete account',
    'deleteWarn': 'This permanently deletes your account and all habits. This cannot be undone. Enter your password to confirm.',
    'errCred': 'Wrong email or password.', 'errEmailUsed': 'This email is already registered.',
    'errWeak': 'Password must be at least 8 characters.', 'errNet': 'No internet connection.',
    'errMany': 'Too many attempts. Try again later.', 'errGeneric': 'Something went wrong. Please try again.',
    'errRequired': 'Required', 'errEmail': 'Enter a valid email.', 'edit': 'Edit',
    'confirm': 'Confirm', 'accountSection': 'Account', 'appearance': 'Appearance',
    'checkSpam': 'The email can take a minute and often lands in your Spam or Promotions folder.',
    'verifyShort': 'Verify your email · check Spam too',
  },
  'fr': {
    'appName': 'Habidz', 'tagline': 'Construisez vos habitudes, un carré à la fois.',
    'login': 'Se connecter', 'signup': "S'inscrire", 'email': 'E-mail', 'password': 'Mot de passe',
    'name': "Nom d'affichage", 'forgot': 'Mot de passe oublié ?', 'resetSent': 'E-mail de réinitialisation envoyé.',
    'haveAccount': 'Déjà un compte ? Se connecter', 'noAccount': "Pas de compte ? S'inscrire",
    'verifyBanner': 'Veuillez vérifier votre e-mail.', 'resend': 'Renvoyer', 'sent': 'E-mail envoyé.',
    'iVerified': "J'ai vérifié", 'profile': 'Profil', 'emptyTitle': "Pas encore d'habitudes",
    'emptySub': 'Appuyez sur + pour ajouter votre première habitude.', 'addHabit': 'Nouvelle habitude',
    'editHabit': "Modifier l'habitude", 'habitName': "Nom de l'habitude", 'icon': 'Icône', 'color': 'Couleur',
    'auto': 'Auto', 'archive': 'Archiver (masquer)', 'save': 'Enregistrer', 'cancel': 'Annuler',
    'delete': 'Supprimer', 'deleteHabitQ': "Supprimer cette habitude et tout son historique ?",
    'streak': 'Série', 'best': 'Record',
    'offline': 'Hors ligne ou synchronisation - modifications enregistrées sur cet appareil.',
    'theme': 'Thème', 'tSystem': 'Système', 'tLight': 'Clair', 'tDark': 'Sombre', 'tPurple': 'Violet premium',
    'language': 'Langue', 'changePw': 'Changer le mot de passe', 'currentPw': 'Mot de passe actuel',
    'newPw': 'Nouveau mot de passe (min 8)', 'pwChanged': 'Mot de passe modifié.',
    'export': 'Exporter mes données', 'exported': 'Données copiées dans le presse-papiers (JSON).',
    'logout': 'Se déconnecter', 'deleteAcc': 'Supprimer le compte',
    'deleteWarn': 'Cela supprime définitivement votre compte et toutes vos habitudes. Irréversible. Entrez votre mot de passe pour confirmer.',
    'errCred': 'E-mail ou mot de passe incorrect.', 'errEmailUsed': 'Cet e-mail est déjà utilisé.',
    'errWeak': 'Le mot de passe doit contenir au moins 8 caractères.', 'errNet': 'Pas de connexion Internet.',
    'errMany': 'Trop de tentatives. Réessayez plus tard.', 'errGeneric': "Une erreur s'est produite. Réessayez.",
    'errRequired': 'Obligatoire', 'errEmail': 'Entrez un e-mail valide.', 'edit': 'Modifier',
    'confirm': 'Confirmer', 'accountSection': 'Compte', 'appearance': 'Apparence',
    'checkSpam': "L'e-mail peut prendre une minute et arrive souvent dans vos Spams ou Promotions.",
    'verifyShort': 'Vérifiez votre e-mail · regardez aussi les spams',
  },
  'ar': {
    'appName': 'هابيدز', 'tagline': 'ابنِ عاداتك، مربعاً بعد مربع.',
    'login': 'تسجيل الدخول', 'signup': 'إنشاء حساب', 'email': 'البريد الإلكتروني', 'password': 'كلمة المرور',
    'name': 'الاسم', 'forgot': 'نسيت كلمة المرور؟', 'resetSent': 'تم إرسال رسالة إعادة التعيين.',
    'haveAccount': 'لديك حساب؟ سجّل الدخول', 'noAccount': 'ليس لديك حساب؟ أنشئ حساباً',
    'verifyBanner': 'يرجى تأكيد بريدك الإلكتروني.', 'resend': 'إعادة الإرسال', 'sent': 'تم إرسال الرسالة.',
    'iVerified': 'لقد أكدت', 'profile': 'الملف الشخصي', 'emptyTitle': 'لا توجد عادات بعد',
    'emptySub': 'اضغط + لإضافة أول عادة.', 'addHabit': 'عادة جديدة', 'editHabit': 'تعديل العادة',
    'habitName': 'اسم العادة', 'icon': 'الأيقونة', 'color': 'اللون', 'auto': 'تلقائي',
    'archive': 'أرشفة (إخفاء)', 'save': 'حفظ', 'cancel': 'إلغاء', 'delete': 'حذف',
    'deleteHabitQ': 'حذف هذه العادة وكل سجلها؟', 'streak': 'التتابع', 'best': 'الأفضل',
    'offline': 'غير متصل أو قيد المزامنة - التغييرات محفوظة على هذا الجهاز.',
    'theme': 'السمة', 'tSystem': 'النظام', 'tLight': 'فاتح', 'tDark': 'داكن', 'tPurple': 'بنفسجي مميز',
    'language': 'اللغة', 'changePw': 'تغيير كلمة المرور', 'currentPw': 'كلمة المرور الحالية',
    'newPw': 'كلمة المرور الجديدة (8 أحرف على الأقل)', 'pwChanged': 'تم تغيير كلمة المرور.',
    'export': 'تصدير بياناتي', 'exported': 'تم نسخ البيانات (JSON) إلى الحافظة.',
    'logout': 'تسجيل الخروج', 'deleteAcc': 'حذف الحساب',
    'deleteWarn': 'سيؤدي هذا إلى حذف حسابك وجميع عاداتك نهائياً ولا يمكن التراجع. أدخل كلمة المرور للتأكيد.',
    'errCred': 'البريد أو كلمة المرور غير صحيحة.', 'errEmailUsed': 'هذا البريد مسجّل مسبقاً.',
    'errWeak': 'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل.', 'errNet': 'لا يوجد اتصال بالإنترنت.',
    'errMany': 'محاولات كثيرة. حاول لاحقاً.', 'errGeneric': 'حدث خطأ. حاول مرة أخرى.',
    'errRequired': 'مطلوب', 'errEmail': 'أدخل بريداً صحيحاً.', 'edit': 'تعديل',
    'confirm': 'تأكيد', 'accountSection': 'الحساب', 'appearance': 'المظهر',
    'checkSpam': 'قد تستغرق الرسالة دقيقة وغالباً تصل إلى البريد العشوائي (Spam) أو الترويجات.',
    'verifyShort': 'أكّد بريدك · تحقق من البريد العشوائي',
  },
};

String tr(BuildContext c, String k) {
  final l = Localizations.localeOf(c).languageCode;
  return _m[l]?[k] ?? _m['en']![k] ?? k;
}

extension Tx on BuildContext {
  String t(String k) => tr(this, k);
}
