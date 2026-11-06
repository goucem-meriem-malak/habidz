import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'habit_repo.dart';
import 'l10n.dart';

String authError(BuildContext c, Object e) {
  if (e is FirebaseAuthException) {
    switch (e.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
      case 'invalid-email':
        return c.t('errCred');
      case 'email-already-in-use':
        return c.t('errEmailUsed');
      case 'weak-password':
        return c.t('errWeak');
      case 'network-request-failed':
        return c.t('errNet');
      case 'too-many-requests':
        return c.t('errMany');
    }
  }
  return c.t('errGeneric');
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _name = TextEditingController();
  bool _signup = false, _busy = false, _hide = true;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final auth = FirebaseAuth.instance;
    try {
      if (_signup) {
        final cred = await auth.createUserWithEmailAndPassword(
            email: _email.text.trim(), password: _pass.text);
        final name = _name.text.trim();
        await cred.user!.updateDisplayName(name);
        habitRepo.createUserDoc(name);
        try {
          await cred.user!.sendEmailVerification();
        } catch (_) {}
      } else {
        await auth.signInWithEmailAndPassword(email: _email.text.trim(), password: _pass.text);
      }
    } catch (e) {
      if (mounted) setState(() => _error = authError(context, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _forgot() async {
    final email = _email.text.trim();
    if (!email.contains('@')) {
      setState(() => _error = context.t('errEmail'));
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } catch (_) {
      // Same message either way: do not reveal whether the email exists.
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.t('resetSent'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.grid_view_rounded, size: 56, color: cs.primary),
                    const SizedBox(height: 12),
                    Text(context.t('appName'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(context.t('tagline'),
                        textAlign: TextAlign.center, style: TextStyle(color: cs.secondary)),
                    const SizedBox(height: 28),
                    if (_signup) ...[
                      TextFormField(
                        controller: _name,
                        maxLength: 60,
                        decoration: InputDecoration(labelText: context.t('name')),
                        validator: (v) => (v == null || v.trim().isEmpty) ? context.t('errRequired') : null,
                      ),
                      const SizedBox(height: 4),
                    ],
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: InputDecoration(labelText: context.t('email')),
                      validator: (v) => (v == null || !v.contains('@')) ? context.t('errEmail') : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _pass,
                      obscureText: _hide,
                      autofillHints: [_signup ? AutofillHints.newPassword : AutofillHints.password],
                      decoration: InputDecoration(
                        labelText: context.t('password'),
                        suffixIcon: IconButton(
                          icon: Icon(_hide ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _hide = !_hide),
                        ),
                      ),
                      validator: (v) => (v == null || v.length < 8) ? context.t('errWeak') : null,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!, style: TextStyle(color: cs.error)),
                    ],
                    const SizedBox(height: 18),
                    FilledButton(
                      onPressed: _busy ? null : _submit,
                      child: _busy
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(context.t(_signup ? 'signup' : 'login')),
                    ),
                    if (!_signup)
                      TextButton(onPressed: _forgot, child: Text(context.t('forgot'))),
                    TextButton(
                      onPressed: () => setState(() {
                        _signup = !_signup;
                        _error = null;
                      }),
                      child: Text(context.t(_signup ? 'haveAccount' : 'noAccount')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
