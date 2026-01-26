// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to login screen after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFF9F8F6),
              const Color(0xFFE8F3F0),
              const Color(0xFF39AC86),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Status Bar Placeholder (iOS style spacing)
            const SizedBox(height: 40),

            // Main Branding Content
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Custom Styled Logo Component
                  Container(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer Plate Glow/Shadow
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: const Color(0xFF39AC86).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF39AC86).withOpacity(0.2),
                                blurRadius: 60,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                        ),

                        // The Logo Assembly
                        Container(
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF39AC86).withOpacity(0.2),
                                blurRadius: 30,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Container(
                            width: 128,
                            height: 128,
                            child: Stack(
                              children: [
                                // Plate Base (solid border)
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xFF39AC86).withOpacity(0.3),
                                      width: 6,
                                    ),
                                    borderRadius: BorderRadius.circular(64),
                                  ),
                                ),

                                // Plate Inner Detail (using dots to simulate dashed)
                                Center(
                                  child: Container(
                                    width: 96,
                                    height: 96,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color(0xFF39AC86).withOpacity(0.2),
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(48),
                                    ),
                                  ),
                                ),

                                // Leaf Icon (using Icons.eco as per your request)
                                Center(
                                  child: Icon(
                                    Icons.eco,
                                    size: 80,
                                    color: const Color(0xFF39AC86),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // App Name & Slogan
                  Container(
                    child: Column(
                      children: [
                        const SizedBox(height: 4),
                        const Text(
                          'Harvest Hub',
                          style: TextStyle(
                            color: Color(0xFF39AC86),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Grow, Share, Sustain',
                          style: TextStyle(
                            color: Color(0xFF101816),
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: 280,
                          child: Text(
                            'Nurturing communities through mindful eating and garden tracking.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFF101816).withOpacity(0.6),
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Progress/Loading Section
            Padding(
              padding: const EdgeInsets.only(bottom: 64),
              child: SizedBox(
                width: 320,
                child: Column(
                  children: [
                    // Loading Text
                    const Text(
                      'Cultivating your garden...',
                      style: TextStyle(
                        color: Color(0xFF101816),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Progress Bar
                    Container(
                      width: double.infinity,
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFF39AC86).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            width: 120, // 45% of 320px
                            height: 6,
                            decoration: BoxDecoration(
                              color: const Color(0xFF39AC86),
                              borderRadius: BorderRadius.circular(3),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF39AC86).withOpacity(0.5),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Version Tag
                    Text(
                      'VERSION 1.0.10',
                      style: TextStyle(
                        color: const Color(0xFF101816).withOpacity(0.3),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Decorative Background Element
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.25,
                child: Opacity(
                  opacity: 0.2,
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBnq98pXrupDrCoo2VZML5fFwmIdq77MEYGnODqkL1q6YBjTIBwBBr7VB0Of9qd8Orgwh8hpqohpKsjrQ9D48Eex4SCvNwBlpBvGQp3o8AbAN06w86_rtV4M3BrOmFZcvppp6THNsrfW9qxpKWgKfFxv-d76clFOh-DCuqWbIcVmYA-ffQTnU-IYVqK9E9JLOioaKUKhzNLMs3Rac6SffZyOSsZfUIWfqxIAGdps-t2U6qZIOcsvAebnc0Xz8fS8HljwHeGXFvAsnvV',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




// // lib/splash_screen.dart
// import 'package:flutter/material.dart';
// import 'login_screen.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // Navigate to login screen after 3 seconds
//     Future.delayed(const Duration(seconds: 3), () {
//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(builder: (context) => const LoginScreen()),
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               const Color(0xFFF9F8F6),
//               const Color(0xFFE8F3F0),
//               const Color(0xFF39AC86),
//             ],
//           ),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Logo
//             Container(
//               width: 180,
//               height: 180,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(100),
//                 boxShadow: [
//                   BoxShadow(
//                     color: const Color(0xFF39AC86).withOpacity(0.3),
//                     blurRadius: 30,
//                     spreadRadius: 5,
//                   ),
//                 ],
//               ),
//               child: Center(
//                 child: Icon(
//                   Icons.eco,
//                   size: 80,
//                   color: const Color(0xFF39AC86),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 32),

//             // App Name
//             const Text(
//               'Harvest Hub',
//               style: TextStyle(
//                 fontSize: 42,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF101816),
//               ),
//             ),

//             const SizedBox(height: 8),

//             // Tagline
//             const Text(
//               'Grow, Share, Sustain',
//               style: TextStyle(
//                 fontSize: 18,
//                 color: Color(0xFF101816),
//               ),
//             ),

//             const SizedBox(height: 60),

//             // Loading text
//             const Text(
//               'Cultivating your garden...',
//               style: TextStyle(
//                 color: Color(0xFF101816),
//                 fontSize: 14,
//               ),
//             ),

//             const SizedBox(height: 16),

//             // Progress Bar
//             Container(
//               width: 200,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: const Color(0xFF39AC86).withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(2),
//               ),
//               child: Stack(
//                 children: [
//                   AnimatedContainer(
//                     duration: const Duration(seconds: 2),
//                     width: 90,
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF39AC86),
//                       borderRadius: BorderRadius.circular(2),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 40),

//             // Version
//             const Text(
//               'VERSION 1.0.10',
//               style: TextStyle(
//                 color: Color(0xFF101816),
//                 fontSize: 12,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
