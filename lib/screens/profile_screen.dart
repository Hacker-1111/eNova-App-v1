import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body:
          user == null
              ? const Center(child: Text('No user logged in'))
              : Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar and User Information
                    Center(
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(
                          user.photoURL ?? 'https://via.placeholder.com/150',
                        ),
                        backgroundColor: Colors.deepPurpleAccent,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        user.displayName ?? 'No Name',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        user.email ?? 'No Email',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Settings Button with Icon
                    ElevatedButton.icon(
                      onPressed: () => _openSettings(context, user),
                      icon: const Icon(Icons.settings, color: Colors.white),
                      label: const Text(
                        'Settings',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Privacy Policy Button with Icon
                    ElevatedButton.icon(
                      onPressed: () => _openPrivacyPolicy(context),
                      icon: const Icon(Icons.privacy_tip, color: Colors.white),
                      label: const Text(
                        'Privacy Policy',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Contact Us Button with Icon
                    ElevatedButton.icon(
                      onPressed: () => _openContactUs(context),
                      icon: const Icon(Icons.contact_mail, color: Colors.white),
                      label: const Text(
                        'Contact Us',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Rate Us Button with Icon
                    ElevatedButton.icon(
                      onPressed: () => _rateUs(context),
                      icon: const Icon(Icons.star_rate, color: Colors.white),
                      label: const Text(
                        'Rate Us',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Logout Button with Icon
                    Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 24,
                          ),
                        ),
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          if (context.mounted) {
                            Navigator.of(
                              context,
                            ).pushReplacementNamed('/login');
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  // Open Settings Screen
  Future<void> _openSettings(BuildContext context, User user) async {
    await showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Settings'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Change Name Option
                ElevatedButton.icon(
                  onPressed: () => _updateName(context, user),
                  icon: const Icon(Icons.edit, color: Colors.white),
                  label: const Text(
                    'Update Name',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 10),
                // Change Email Option
                ElevatedButton.icon(
                  onPressed: () => _changeEmail(context, user),
                  icon: const Icon(Icons.email, color: Colors.white),
                  label: const Text(
                    'Change Email',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 10),
                // Change Password Option
                ElevatedButton.icon(
                  onPressed: () => _changePassword(context, user),
                  icon: const Icon(Icons.lock, color: Colors.white),
                  label: const Text(
                    'Change Password',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }

  // Open Privacy Policy
  Future<void> _openPrivacyPolicy(BuildContext context) async {
    await showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Privacy Policy'),
            content: const Text(
              'This is our Privacy Policy. We value your privacy and ensure the '
              'security of your data. Please read the terms carefully.',
            ),
            actions: [
              TextButton(
                child: const Text('Close'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }

  // Open Contact Us Screen
  Future<void> _openContactUs(BuildContext context) async {
    await showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Contact Us'),
            content: const Text(
              'You can reach us at:\n'
              'Email: support@enovaapp.com\n'
              'Phone: +201010764089\n'
              'We will be happy to assist you!',
            ),
            actions: [
              TextButton(
                child: const Text('Close'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }

  // Open Rate Us Screen
  Future<void> _rateUs(BuildContext context) async {
    double rating = 0;

    await showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Rate Us'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'If you enjoy using our app, please rate us!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                RatingBar.builder(
                  initialRating: rating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: 40,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder:
                      (context, _) =>
                          const Icon(Icons.star, color: Colors.deepPurple),
                  onRatingUpdate: (ratingValue) {
                    rating = ratingValue;
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                child: const Text('Submit'),
                onPressed: () {
                  // Here you can send the rating to a backend or just print it for now
                  print('User rated: $rating stars');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
    );
  }

  // Update Name Function
  Future<void> _updateName(BuildContext context, User user) async {
    TextEditingController nameController = TextEditingController();

    await showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Update Name'),
            content: TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'New Name'),
            ),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                child: const Text('Update'),
                onPressed: () async {
                  if (nameController.text.isNotEmpty) {
                    try {
                      await user.updateDisplayName(nameController.text);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Name updated successfully!'),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Error updating name')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
    );
  }

  // Change Email Function
  Future<void> _changeEmail(BuildContext context, User user) async {
    TextEditingController emailController = TextEditingController();

    await showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Change Email'),
            content: TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'New Email'),
            ),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                child: const Text('Update'),
                onPressed: () async {
                  if (emailController.text.contains('@')) {
                    try {
                      final credentials = EmailAuthProvider.credential(
                        email: user.email!,
                        password: 'your_current_password_here',
                      );
                      await user.reauthenticateWithCredential(credentials);
                      await user.updateEmail(emailController.text);
                      await user.sendEmailVerification();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Email updated successfully!'),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Error updating email')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
    );
  }

  // Change Password Function
  Future<void> _changePassword(BuildContext context, User user) async {
    TextEditingController passwordController = TextEditingController();

    await showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Change Password'),
            content: TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password'),
            ),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                child: const Text('Update'),
                onPressed: () async {
                  if (passwordController.text.length >= 6) {
                    try {
                      final credentials = EmailAuthProvider.credential(
                        email: user.email!,
                        password: 'your_current_password_here',
                      );
                      await user.reauthenticateWithCredential(credentials);
                      await user.updatePassword(passwordController.text);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Password updated successfully!'),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Error updating password'),
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
    );
  }
}
