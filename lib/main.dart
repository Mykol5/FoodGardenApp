// main.dart - HTML-like splash screen works
// main.dart - FIXED arrangement version
import 'package:flutter/material.dart';
import 'login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Harvest Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF39AC86),
        scaffoldBackgroundColor: const Color(0xFFF9F8F6),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF39AC86),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        primaryColor: const Color(0xFF39AC86),
        scaffoldBackgroundColor: const Color(0xFF212C28),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF39AC86),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF9F8F6),
              Color(0xFFE8F3F0),
              Color(0xFF39AC86),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Status Bar Placeholder
            const Positioned(
              top: 40,
              left: 0,
              right: 0,
              child: SizedBox(height: 40),
            ),

            // UPPER CONTENT - Logo and Main Text
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo - Moved UP
                      Container(
                        margin: const EdgeInsets.only(bottom: 30), // Reduced from 40
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer glow
                            Container(
                              width: 180, // Reduced from 200
                              height: 180, // Reduced from 200
                              decoration: BoxDecoration(
                                color: const Color(0xFF39AC86).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                            // White circle with shadow
                            Container(
                              padding: const EdgeInsets.all(36), // Reduced from 40
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
                              ),
                              child: Container(
                                width: 112, // Reduced from 128
                                height: 112, // Reduced from 128
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(64),
                                  border: Border.all(
                                    color: const Color(0xFF39AC86).withOpacity(0.3),
                                    width: 6,
                                  ),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 84, // Reduced from 96
                                    height: 84, // Reduced from 96
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(48),
                                      border: Border.all(
                                        color: const Color(0xFF39AC86).withOpacity(0.2),
                                        width: 2,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.eco,
                                        size: 70, // Reduced from 80
                                        color: Color(0xFF39AC86),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Title and Tagline
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'HARVEST HUB',
                            style: TextStyle(
                              color: Color(0xFF39AC86),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3,
                            ),
                          ),
                          const SizedBox(height: 12), // Reduced from 16
                          const Text(
                            'Grow, Share,\nSustain', // Back to 2 lines as in PNG
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF101816),
                              fontSize: 32, // Reduced from 36
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 16), // Reduced from 20
                          SizedBox(
                            width: 280,
                            child: Column(
                              children: [
                                Text(
                                  'Nurturing communities through',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: const Color(0xFF101816).withOpacity(0.6),
                                    fontSize: 14, // Reduced from 16
                                    fontWeight: FontWeight.w500,
                                    height: 1.3,
                                  ),
                                ),
                                Text(
                                  'mindful eating and garden',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: const Color(0xFF101816).withOpacity(0.6),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    height: 1.3,
                                  ),
                                ),
                                Text(
                                  'tracking.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: const Color(0xFF101816).withOpacity(0.6),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // LOWER CONTENT - Much lower position
            Positioned(
              bottom: 60, // Moved UP from 100 to give space for version text
              left: 0,
              right: 0,
              child: Column(
                children: [
                  const Text(
                    'Cultivating your garden...',
                    style: TextStyle(
                      color: Color(0xFF101816),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12), // Reduced from 16
                  Container(
                    width: 300, // Reduced from 320
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF39AC86).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 120,
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
                    ),
                  ),
                ],
              ),
            ),

            // VERSION TEXT - At the very bottom
            Positioned(
              bottom: 20, // Very close to bottom
              left: 0,
              right: 0,
              child: Text(
                'VERSION 1.0.10',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF101816).withOpacity(0.3),
                  fontSize: 11, // Reduced from 12
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
            ),

            // Subtle background gradient - Reduced height
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.15, // Reduced from 0.25
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      const Color(0xFF39AC86).withOpacity(0.1),
                      Colors.transparent,
                    ],
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

// // main.dart - Fixed version
// import 'package:flutter/material.dart';
// import 'login_screen.dart'; // Make sure you have this file

// // Main entry point - REQUIRED by Flutter
// void main() {
//   runApp(const MyApp());
// }

// // Main app widget
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Harvest Hub',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primaryColor: const Color(0xFF39AC86),
//         scaffoldBackgroundColor: const Color(0xFFF9F8F6),
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: const Color(0xFF39AC86),
//           brightness: Brightness.light,
//         ),
//         useMaterial3: true,
//       ),
//       darkTheme: ThemeData(
//         primaryColor: const Color(0xFF39AC86),
//         scaffoldBackgroundColor: const Color(0xFF212C28),
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: const Color(0xFF39AC86),
//           brightness: Brightness.dark,
//         ),
//         useMaterial3: true,
//       ),
//       home: const SplashScreen(), // Set SplashScreen as home
//     );
//   }
// }

// // Splash Screen Widget - SIMPLIFIED VERSION
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
//       if (mounted) {
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(builder: (context) => const LoginScreen()),
//         );
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Color(0xFFF9F8F6),
//               Color(0xFFE8F3F0),
//               Color(0xFF39AC86),
//             ],
//           ),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             // Simplified Logo
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




// // main.dart - This file contains BOTH the main() function AND SplashScreen
// import 'package:flutter/material.dart';
// import 'login_screen.dart'; // Make sure you have this file

// // Main entry point - REQUIRED by Flutter
// void main() {
//   runApp(const MyApp());
// }

// // Main app widget
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Harvest Hub',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primaryColor: const Color(0xFF39AC86),
//         scaffoldBackgroundColor: const Color(0xFFF9F8F6),
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: const Color(0xFF39AC86),
//           brightness: Brightness.light,
//         ),
//         useMaterial3: true,
//       ),
//       darkTheme: ThemeData(
//         primaryColor: const Color(0xFF39AC86),
//         scaffoldBackgroundColor: const Color(0xFF212C28),
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: const Color(0xFF39AC86),
//           brightness: Brightness.dark,
//         ),
//         useMaterial3: true,
//       ),
//       home: const SplashScreen(), // Set SplashScreen as home
//     );
//   }
// }

// // Splash Screen Widget
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
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             // Status Bar Placeholder (iOS style spacing)
//             const SizedBox(height: 40),

//             // Main Branding Content
//             Expanded(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // Custom Styled Logo Component
//                   Container(
//                     child: Stack(
//                       alignment: Alignment.center,
//                       children: [
//                         // Outer Plate Glow/Shadow
//                         Container(
//                           width: 200,
//                           height: 200,
//                           decoration: BoxDecoration(
//                             color: const Color(0xFF39AC86).withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(100),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: const Color(0xFF39AC86).withOpacity(0.2),
//                                 blurRadius: 60,
//                                 spreadRadius: 10,
//                               ),
//                             ],
//                           ),
//                         ),

//                         // The Logo Assembly
//                         Container(
//                           padding: const EdgeInsets.all(40),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(100),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: const Color(0xFF39AC86).withOpacity(0.2),
//                                 blurRadius: 30,
//                                 offset: const Offset(0, 4),
//                               ),
//                             ],
//                             border: Border.all(
//                               color: Colors.white.withOpacity(0.5),
//                               width: 1,
//                             ),
//                           ),
//                           child: Container(
//                             width: 128,
//                             height: 128,
//                             child: Stack(
//                               children: [
//                                 // Plate Base (solid border)
//                                 Container(
//                                   decoration: BoxDecoration(
//                                     border: Border.all(
//                                       color: const Color(0xFF39AC86).withOpacity(0.3),
//                                       width: 6,
//                                     ),
//                                     borderRadius: BorderRadius.circular(64),
//                                   ),
//                                 ),

//                                 // Plate Inner Detail (using dots to simulate dashed)
//                                 Center(
//                                   child: Container(
//                                     width: 96,
//                                     height: 96,
//                                     decoration: BoxDecoration(
//                                       border: Border.all(
//                                         color: const Color(0xFF39AC86).withOpacity(0.2),
//                                         width: 2,
//                                       ),
//                                       borderRadius: BorderRadius.circular(48),
//                                     ),
//                                   ),
//                                 ),

//                                 // Leaf Icon (using Icons.eco as per your request)
//                                 Center(
//                                   child: Icon(
//                                     Icons.eco,
//                                     size: 80,
//                                     color: const Color(0xFF39AC86),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 32),

//                   // App Name & Slogan
//                   Container(
//                     child: Column(
//                       children: [
//                         const SizedBox(height: 4),
//                         const Text(
//                           'Harvest Hub',
//                           style: TextStyle(
//                             color: Color(0xFF39AC86),
//                             fontSize: 12,
//                             fontWeight: FontWeight.bold,
//                             letterSpacing: 3,
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                         const Text(
//                           'Grow, Share, Sustain',
//                           style: TextStyle(
//                             color: Color(0xFF101816),
//                             fontSize: 42,
//                             fontWeight: FontWeight.bold,
//                             letterSpacing: -0.5,
//                             height: 1,
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         SizedBox(
//                           width: 280,
//                           child: Text(
//                             'Nurturing communities through mindful eating and garden tracking.',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               color: const Color(0xFF101816).withOpacity(0.6),
//                               fontSize: 18,
//                               fontWeight: FontWeight.w500,
//                               height: 1.5,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Progress/Loading Section
//             Padding(
//               padding: const EdgeInsets.only(bottom: 64),
//               child: SizedBox(
//                 width: 320,
//                 child: Column(
//                   children: [
//                     // Loading Text
//                     const Text(
//                       'Cultivating your garden...',
//                       style: TextStyle(
//                         color: Color(0xFF101816),
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                         letterSpacing: 0.5,
//                       ),
//                     ),

//                     const SizedBox(height: 12),

//                     // Progress Bar
//                     Container(
//                       width: double.infinity,
//                       height: 6,
//                       decoration: BoxDecoration(
//                         color: const Color(0xFF39AC86).withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(3),
//                       ),
//                       child: Stack(
//                         children: [
//                           Container(
//                             width: 120, // 45% of 320px
//                             height: 6,
//                             decoration: BoxDecoration(
//                               color: const Color(0xFF39AC86),
//                               borderRadius: BorderRadius.circular(3),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: const Color(0xFF39AC86).withOpacity(0.5),
//                                   blurRadius: 10,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     const SizedBox(height: 32),

//                     // Version Tag
//                     Text(
//                       'VERSION 1.0.10',
//                       style: TextStyle(
//                         color: const Color(0xFF101816).withOpacity(0.3),
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                         letterSpacing: 2,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             // Decorative Background Element
//             Positioned(
//               bottom: 0,
//               left: 0,
//               child: Container(
//                 width: MediaQuery.of(context).size.width,
//                 height: MediaQuery.of(context).size.height * 0.25,
//                 child: Opacity(
//                   opacity: 0.2,
//                   child: Image.network(
//                     'https://lh3.googleusercontent.com/aida-public/AB6AXuBnq98pXrupDrCoo2VZML5fFwmIdq77MEYGnODqkL1q6YBjTIBwBBr7VB0Of9qd8Orgwh8hpqohpKsjrQ9D48Eex4SCvNwBlpBvGQp3o8AbAN06w86_rtV4M3BrOmFZcvppp6THNsrfW9qxpKWgKfFxv-d76clFOh-DCuqWbIcVmYA-ffQTnU-IYVqK9E9JLOioaKUKhzNLMs3Rac6SffZyOSsZfUIWfqxIAGdps-t2U6qZIOcsvAebnc0Xz8fS8HljwHeGXFvAsnvV',
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



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








// // main.dart
// import 'package:flutter/material.dart';
// import 'splash_screen.dart'; // Import the splash screen

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Harvest Hub',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primaryColor: const Color(0xFF39AC86),
//         scaffoldBackgroundColor: const Color(0xFFF9F8F6),
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: const Color(0xFF39AC86),
//           brightness: Brightness.light,
//         ),
//         useMaterial3: true,
//       ),
//       darkTheme: ThemeData(
//         primaryColor: const Color(0xFF39AC86),
//         scaffoldBackgroundColor: const Color(0xFF212C28),
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: const Color(0xFF39AC86),
//           brightness: Brightness.dark,
//         ),
//         useMaterial3: true,
//       ),
//       home: const SplashScreen(), // Start with splash screen
//     );
//   }
// }









// // import 'package:flutter/material.dart';
// // import 'main_layout.dart'; 

// // void main() {
// //   runApp(const MyApp());
// // }

// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'Harvest Hub',
// //       debugShowCheckedModeBanner: false,
// //       theme: ThemeData(
// //         primaryColor: const Color(0xFF39AC86),
// //         scaffoldBackgroundColor: const Color(0xFFF9F8F6),
// //         colorScheme: ColorScheme.fromSeed(
// //           seedColor: const Color(0xFF39AC86),
// //           brightness: Brightness.light,
// //         ),
// //         useMaterial3: true,
// //       ),
// //       darkTheme: ThemeData(
// //         primaryColor: const Color(0xFF39AC86),
// //         scaffoldBackgroundColor: const Color(0xFF212C28),
// //         colorScheme: ColorScheme.fromSeed(
// //           seedColor: const Color(0xFF39AC86),
// //           brightness: Brightness.dark,
// //         ),
// //         useMaterial3: true,
// //       ),
// //       home: const SplashScreen(),
// //     );
// //   }
// // }

// // // ==================== SPLASH SCREEN ====================
// // class SplashScreen extends StatefulWidget {
// //   const SplashScreen({super.key});

// //   @override
// //   State<SplashScreen> createState() => _SplashScreenState();
// // }

// // class _SplashScreenState extends State<SplashScreen> {
// //   @override
// //   void initState() {
// //     super.initState();
// //     // Navigate to login screen after 3 seconds
// //     Future.delayed(const Duration(seconds: 3), () {
// //       Navigator.of(context).pushReplacement(
// //         MaterialPageRoute(builder: (context) => const LoginScreen()),
// //       );
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: Container(
// //         width: double.infinity,
// //         height: double.infinity,
// //         decoration: BoxDecoration(
// //           gradient: LinearGradient(
// //             begin: Alignment.topCenter,
// //             end: Alignment.bottomCenter,
// //             colors: [
// //               const Color(0xFFF9F8F6),
// //               const Color(0xFFE8F3F0),
// //               const Color(0xFF39AC86),
// //             ],
// //           ),
// //         ),
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             // Logo
// //             Container(
// //               width: 180,
// //               height: 180,
// //               decoration: BoxDecoration(
// //                 color: Colors.white,
// //                 borderRadius: BorderRadius.circular(100),
// //                 boxShadow: [
// //                   BoxShadow(
// //                     color: const Color(0xFF39AC86).withOpacity(0.3),
// //                     blurRadius: 30,
// //                     spreadRadius: 5,
// //                   ),
// //                 ],
// //               ),
// //               child: Center(
// //                 child: Icon(
// //                   Icons.eco,
// //                   size: 80,
// //                   color: const Color(0xFF39AC86),
// //                 ),
// //               ),
// //             ),

// //             const SizedBox(height: 32),

// //             // App Name
// //             const Text(
// //               'Harvest Hub',
// //               style: TextStyle(
// //                 fontSize: 42,
// //                 fontWeight: FontWeight.bold,
// //                 color: Color(0xFF101816),
// //               ),
// //             ),

// //             const SizedBox(height: 8),

// //             // Tagline
// //             const Text(
// //               'Grow, Share, Sustain',
// //               style: TextStyle(
// //                 fontSize: 18,
// //                 color: Color(0xFF101816),
// //               ),
// //             ),

// //             const SizedBox(height: 60),

// //             // Loading text
// //             const Text(
// //               'Cultivating your garden...',
// //               style: TextStyle(
// //                 color: Color(0xFF101816),
// //                 fontSize: 14,
// //               ),
// //             ),

// //             const SizedBox(height: 16),

// //             // Progress Bar
// //             Container(
// //               width: 200,
// //               height: 4,
// //               decoration: BoxDecoration(
// //                 color: const Color(0xFF39AC86).withOpacity(0.2),
// //                 borderRadius: BorderRadius.circular(2),
// //               ),
// //               child: Stack(
// //                 children: [
// //                   AnimatedContainer(
// //                     duration: const Duration(seconds: 2),
// //                     width: 90,
// //                     decoration: BoxDecoration(
// //                       color: const Color(0xFF39AC86),
// //                       borderRadius: BorderRadius.circular(2),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),

// //             const SizedBox(height: 40),

// //             // Version
// //             const Text(
// //               'VERSION 1.0.10',
// //               style: TextStyle(
// //                 color: Color(0xFF101816),
// //                 fontSize: 12,
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// // // ==================== LOGIN SCREEN ====================
// // class LoginScreen extends StatefulWidget {
// //   const LoginScreen({super.key});

// //   @override
// //   State<LoginScreen> createState() => _LoginScreenState();
// // }

// // class _LoginScreenState extends State<LoginScreen> {
// //   bool _isLogin = true;
// //   final _emailController = TextEditingController();
// //   final _passwordController = TextEditingController();
// //   final _confirmPasswordController = TextEditingController();
// //   final _phoneController = TextEditingController();
// //   bool _obscurePassword = true;
// //   bool _obscureConfirmPassword = true;

// //   @override
// //   void dispose() {
// //     _emailController.dispose();
// //     _passwordController.dispose();
// //     _confirmPasswordController.dispose();
// //     _phoneController.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final isDarkMode = Theme.of(context).brightness == Brightness.dark;

// //     return Scaffold(
// //       backgroundColor: isDarkMode ? const Color(0xFF212C28) : const Color(0xFFF9F8F6),
// //       body: SafeArea(
// //         child: SingleChildScrollView(
// //           child: Container(
// //             constraints: BoxConstraints(
// //               minHeight: MediaQuery.of(context).size.height,
// //             ),
// //             width: double.infinity,
// //             child: Column(
// //               children: [
// //                 // Hero Section with Image
// //                 Container(
// //                   height: 280,
// //                   width: double.infinity,
// //                   decoration: BoxDecoration(
// //                     color: const Color(0xFFE0E8E4),
// //                     borderRadius: const BorderRadius.only(
// //                       bottomLeft: Radius.circular(20),
// //                       bottomRight: Radius.circular(20),
// //                     ),
// //                     image: const DecorationImage(
// //                       image: NetworkImage(
// //                         'https://images.unsplash.com/photo-1592417817098-8fd3d9eb14a5?q=80&w=2087&auto=format&fit=crop',
// //                       ),
// //                       fit: BoxFit.cover,
// //                     ),
// //                   ),
// //                   child: Container(
// //                     decoration: BoxDecoration(
// //                       gradient: LinearGradient(
// //                         begin: Alignment.bottomCenter,
// //                         end: Alignment.topCenter,
// //                         colors: [
// //                           isDarkMode 
// //                               ? const Color(0xFF212C28).withOpacity(0.9)
// //                               : const Color(0xFFF9F8F6).withOpacity(0.9),
// //                           Colors.transparent,
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                 ),

// //                 // Title and Description
// //                 Container(
// //                   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
// //                   child: Column(
// //                     children: [
// //                       Text(
// //                         'Rooted in Community',
// //                         style: TextStyle(
// //                           fontSize: 32,
// //                           fontWeight: FontWeight.bold,
// //                           color: isDarkMode ? Colors.white : const Color(0xFF101816),
// //                         ),
// //                         textAlign: TextAlign.center,
// //                       ),
// //                       const SizedBox(height: 8),
// //                       Text(
// //                         'Join 5,000+ local gardeners sharing their harvest and tracking sustainability.',
// //                         style: TextStyle(
// //                           fontSize: 14,
// //                           color: isDarkMode ? const Color(0xFFA1B8B0) : const Color(0xFF5C8A7A),
// //                           fontWeight: FontWeight.w500,
// //                         ),
// //                         textAlign: TextAlign.center,
// //                       ),
// //                     ],
// //                   ),
// //                 ),

// //                 // Login/Signup Toggle
// //                 Container(
// //                   margin: const EdgeInsets.symmetric(horizontal: 24),
// //                   height: 48,
// //                   decoration: BoxDecoration(
// //                     color: isDarkMode ? const Color(0xFF2D3A35) : const Color(0xFFECE9E3),
// //                     borderRadius: BorderRadius.circular(12),
// //                   ),
// //                   child: Row(
// //                     children: [
// //                       Expanded(
// //                         child: GestureDetector(
// //                           onTap: () {
// //                             setState(() {
// //                               _isLogin = true;
// //                             });
// //                           },
// //                           child: Container(
// //                             decoration: BoxDecoration(
// //                               color: _isLogin
// //                                   ? (isDarkMode ? const Color(0xFF39AC86) : Colors.white)
// //                                   : Colors.transparent,
// //                               borderRadius: BorderRadius.circular(10),
// //                               boxShadow: _isLogin
// //                                   ? [
// //                                       BoxShadow(
// //                                         color: Colors.black.withOpacity(0.1),
// //                                         blurRadius: 2,
// //                                         offset: const Offset(0, 1),
// //                                       ),
// //                                     ]
// //                                   : null,
// //                             ),
// //                             child: Center(
// //                               child: Text(
// //                                 'Login',
// //                                 style: TextStyle(
// //                                   fontSize: 14,
// //                                   fontWeight: FontWeight.w600,
// //                                   color: _isLogin
// //                                       ? (isDarkMode ? Colors.white : const Color(0xFF39AC86))
// //                                       : const Color(0xFF5C8A7A),
// //                                 ),
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                       Expanded(
// //                         child: GestureDetector(
// //                           onTap: () {
// //                             setState(() {
// //                               _isLogin = false;
// //                             });
// //                           },
// //                           child: Container(
// //                             decoration: BoxDecoration(
// //                               color: !_isLogin
// //                                   ? (isDarkMode ? const Color(0xFF39AC86) : Colors.white)
// //                                   : Colors.transparent,
// //                               borderRadius: BorderRadius.circular(10),
// //                               boxShadow: !_isLogin
// //                                   ? [
// //                                       BoxShadow(
// //                                         color: Colors.black.withOpacity(0.1),
// //                                         blurRadius: 2,
// //                                         offset: const Offset(0, 1),
// //                                       ),
// //                                     ]
// //                                   : null,
// //                             ),
// //                             child: Center(
// //                               child: Text(
// //                                 'Sign Up',
// //                                 style: TextStyle(
// //                                   fontSize: 14,
// //                                   fontWeight: FontWeight.w600,
// //                                   color: !_isLogin
// //                                       ? (isDarkMode ? Colors.white : const Color(0xFF39AC86))
// //                                       : const Color(0xFF5C8A7A),
// //                                 ),
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),

// //                 // Form Fields
// //                 Padding(
// //                   padding: const EdgeInsets.all(24),
// //                   child: Column(
// //                     children: [
// //                       // Email Field
// //                       Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Text(
// //                             'Garden Email',
// //                             style: TextStyle(
// //                               fontSize: 14,
// //                               fontWeight: FontWeight.w600,
// //                               color: isDarkMode ? Colors.white : const Color(0xFF101816),
// //                             ),
// //                           ),
// //                           const SizedBox(height: 8),
// //                           Container(
// //                             height: 56,
// //                             decoration: BoxDecoration(
// //                               color: isDarkMode ? const Color(0xFF2D3A35) : const Color(0xFFFDFBF7),
// //                               borderRadius: BorderRadius.circular(12),
// //                               border: Border.all(
// //                                 color: isDarkMode ? const Color(0xFF3D4D47) : const Color(0xFFD4E2DE),
// //                               ),
// //                             ),
// //                             child: TextField(
// //                               controller: _emailController,
// //                               decoration: InputDecoration(
// //                                 hintText: 'your@garden.com',
// //                                 hintStyle: TextStyle(
// //                                   color: const Color(0xFFA1B8B0),
// //                                 ),
// //                                 border: InputBorder.none,
// //                                 contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
// //                                 suffixIcon: Padding(
// //                                   padding: const EdgeInsets.only(right: 8),
// //                                   child: Icon(
// //                                     Icons.local_florist,
// //                                     color: const Color(0xFF39AC86).withOpacity(0.6),
// //                                   ),
// //                                 ),
// //                               ),
// //                             ),
// //                           ),
// //                         ],
// //                       ),

// //                       const SizedBox(height: 20),

// //                       // Phone Field (only for Sign Up)
// //                       if (!_isLogin) ...[
// //                         Column(
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [
// //                             Text(
// //                               'Phone Number',
// //                               style: TextStyle(
// //                                 fontSize: 14,
// //                                 fontWeight: FontWeight.w600,
// //                                 color: isDarkMode ? Colors.white : const Color(0xFF101816),
// //                               ),
// //                             ),
// //                             const SizedBox(height: 8),
// //                             Container(
// //                               height: 56,
// //                               decoration: BoxDecoration(
// //                                 color: isDarkMode ? const Color(0xFF2D3A35) : const Color(0xFFFDFBF7),
// //                                 borderRadius: BorderRadius.circular(12),
// //                                 border: Border.all(
// //                                   color: isDarkMode ? const Color(0xFF3D4D47) : const Color(0xFFD4E2DE),
// //                                 ),
// //                               ),
// //                               child: TextField(
// //                                 controller: _phoneController,
// //                                 keyboardType: TextInputType.phone,
// //                                 decoration: InputDecoration(
// //                                   hintText: '+1 (555) 123-4567',
// //                                   hintStyle: TextStyle(
// //                                     color: const Color(0xFFA1B8B0),
// //                                   ),
// //                                   border: InputBorder.none,
// //                                   contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
// //                                   suffixIcon: Padding(
// //                                     padding: const EdgeInsets.only(right: 8),
// //                                     child: Icon(
// //                                       Icons.phone,
// //                                       color: const Color(0xFF5C8A7A),
// //                                     ),
// //                                   ),
// //                                 ),
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                         const SizedBox(height: 20),
// //                       ],

// //                       // Password Field
// //                       Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Row(
// //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                             children: [
// //                               Text(
// //                                 'Secure Password',
// //                                 style: TextStyle(
// //                                   fontSize: 14,
// //                                   fontWeight: FontWeight.w600,
// //                                   color: isDarkMode ? Colors.white : const Color(0xFF101816),
// //                                 ),
// //                               ),
// //                               if (_isLogin)
// //                                 TextButton(
// //                                   onPressed: () {
// //                                     // Forgot password action
// //                                   },
// //                                   child: Text(
// //                                     'Forgot?',
// //                                     style: TextStyle(
// //                                       fontSize: 12,
// //                                       fontWeight: FontWeight.bold,
// //                                       color: const Color(0xFFE59866),
// //                                     ),
// //                                   ),
// //                                 ),
// //                             ],
// //                           ),
// //                           const SizedBox(height: 8),
// //                           Container(
// //                             height: 56,
// //                             decoration: BoxDecoration(
// //                               color: isDarkMode ? const Color(0xFF2D3A35) : const Color(0xFFFDFBF7),
// //                               borderRadius: BorderRadius.circular(12),
// //                               border: Border.all(
// //                                 color: isDarkMode ? const Color(0xFF3D4D47) : const Color(0xFFD4E2DE),
// //                               ),
// //                             ),
// //                             child: TextField(
// //                               controller: _passwordController,
// //                               obscureText: _obscurePassword,
// //                               decoration: InputDecoration(
// //                                 hintText: '••••••••',
// //                                 hintStyle: TextStyle(
// //                                   color: const Color(0xFFA1B8B0),
// //                                 ),
// //                                 border: InputBorder.none,
// //                                 contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
// //                                 suffixIcon: Padding(
// //                                   padding: const EdgeInsets.only(right: 8),
// //                                   child: IconButton(
// //                                     icon: Icon(
// //                                       _obscurePassword ? Icons.visibility : Icons.visibility_off,
// //                                       color: const Color(0xFF5C8A7A),
// //                                     ),
// //                                     onPressed: () {
// //                                       setState(() {
// //                                         _obscurePassword = !_obscurePassword;
// //                                       });
// //                                     },
// //                                   ),
// //                                 ),
// //                               ),
// //                             ),
// //                           ),
// //                           const SizedBox(height: 8),
// //                           Text(
// //                             'Tip: Use 8+ characters with a mix of letters and symbols.',
// //                             style: TextStyle(
// //                               fontSize: 11,
// //                               color: const Color(0xFF5C8A7A),
// //                             ),
// //                           ),
// //                         ],
// //                       ),

// //                       // Confirm Password Field (only for Sign Up)
// //                       if (!_isLogin) ...[
// //                         const SizedBox(height: 20),
// //                         Column(
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [
// //                             Text(
// //                               'Confirm Password',
// //                               style: TextStyle(
// //                                 fontSize: 14,
// //                                 fontWeight: FontWeight.w600,
// //                                 color: isDarkMode ? Colors.white : const Color(0xFF101816),
// //                               ),
// //                             ),
// //                             const SizedBox(height: 8),
// //                             Container(
// //                               height: 56,
// //                               decoration: BoxDecoration(
// //                                 color: isDarkMode ? const Color(0xFF2D3A35) : const Color(0xFFFDFBF7),
// //                                 borderRadius: BorderRadius.circular(12),
// //                                 border: Border.all(
// //                                   color: isDarkMode ? const Color(0xFF3D4D47) : const Color(0xFFD4E2DE),
// //                                 ),
// //                               ),
// //                               child: TextField(
// //                                 controller: _confirmPasswordController,
// //                                 obscureText: _obscureConfirmPassword,
// //                                 decoration: InputDecoration(
// //                                   hintText: '••••••••',
// //                                   hintStyle: TextStyle(
// //                                     color: const Color(0xFFA1B8B0),
// //                                   ),
// //                                   border: InputBorder.none,
// //                                   contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
// //                                   suffixIcon: Padding(
// //                                     padding: const EdgeInsets.only(right: 8),
// //                                     child: IconButton(
// //                                       icon: Icon(
// //                                         _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
// //                                         color: const Color(0xFF5C8A7A),
// //                                       ),
// //                                       onPressed: () {
// //                                         setState(() {
// //                                           _obscureConfirmPassword = !_obscureConfirmPassword;
// //                                         });
// //                                       },
// //                                     ),
// //                                   ),
// //                                 ),
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ],

// //                       const SizedBox(height: 24),

// //                       // Login/Signup Button
// //                       Container(
// //                         width: double.infinity,
// //                         height: 56,
// //                         decoration: BoxDecoration(
// //                           color: const Color(0xFF39AC86),
// //                           borderRadius: BorderRadius.circular(12),
// //                           boxShadow: [
// //                             BoxShadow(
// //                               color: const Color(0xFF39AC86).withOpacity(0.3),
// //                               blurRadius: 10,
// //                               offset: const Offset(0, 4),
// //                             ),
// //                           ],
// //                         ),
// //                         child: Material(
// //                           color: Colors.transparent,
// //                           child: InkWell(
// //                             borderRadius: BorderRadius.circular(12),
// //                             onTap: () {
// //                               // Validate and handle login/signup
// //                               if (_isLogin) {
// //                                 if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
// //                                   ScaffoldMessenger.of(context).showSnackBar(
// //                                     const SnackBar(
// //                                       content: Text('Please enter email and password'),
// //                                     ),
// //                                   );
// //                                 } else {
// //                                   Navigator.of(context).pushReplacement(
// //                                     MaterialPageRoute(
// //                                       builder: (context) => const MainLayout(),
// //                                     ),
// //                                   );
// //                                 }
// //                               } else {
// //                                 // Sign up validation
// //                                 if (_emailController.text.isEmpty ||
// //                                     _passwordController.text.isEmpty ||
// //                                     _confirmPasswordController.text.isEmpty ||
// //                                     _phoneController.text.isEmpty) {
// //                                   ScaffoldMessenger.of(context).showSnackBar(
// //                                     const SnackBar(
// //                                       content: Text('Please fill all fields'),
// //                                     ),
// //                                   );
// //                                 } else if (_passwordController.text != _confirmPasswordController.text) {
// //                                   ScaffoldMessenger.of(context).showSnackBar(
// //                                     const SnackBar(
// //                                       content: Text('Passwords do not match'),
// //                                     ),
// //                                   );
// //                                 } else {
// //                                   Navigator.of(context).pushReplacement(
// //                                     MaterialPageRoute(
// //                                       builder: (context) => const MainLayout(),
// //                                     ),
// //                                   );
// //                                 }
// //                               }
// //                             },
// //                             child: Row(
// //                               mainAxisAlignment: MainAxisAlignment.center,
// //                               children: [
// //                                 Text(
// //                                   _isLogin ? 'Login to Garden' : 'Join the Garden',
// //                                   style: const TextStyle(
// //                                     color: Colors.white,
// //                                     fontSize: 18,
// //                                     fontWeight: FontWeight.bold,
// //                                   ),
// //                                 ),
// //                                 const SizedBox(width: 8),
// //                                 const Icon(
// //                                   Icons.eco,
// //                                   color: Colors.white,
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                         ),
// //                       ),

// //                       const SizedBox(height: 24),

// //                       // Divider
// //                       Row(
// //                         children: [
// //                           Expanded(
// //                             child: Divider(
// //                               color: isDarkMode ? const Color(0xFF3D4D47) : const Color(0xFFD4E2DE),
// //                               thickness: 1,
// //                             ),
// //                           ),
// //                           Padding(
// //                             padding: const EdgeInsets.symmetric(horizontal: 16),
// //                             child: Text(
// //                               'Or continue with',
// //                               style: TextStyle(
// //                                 fontSize: 12,
// //                                 fontWeight: FontWeight.bold,
// //                                 color: const Color(0xFFA1B8B0),
// //                                 letterSpacing: 2,
// //                               ),
// //                             ),
// //                           ),
// //                           Expanded(
// //                             child: Divider(
// //                               color: isDarkMode ? const Color(0xFF3D4D47) : const Color(0xFFD4E2DE),
// //                               thickness: 1,
// //                             ),
// //                           ),
// //                         ],
// //                       ),

// //                       const SizedBox(height: 24),

// //                       // Social Login Buttons
// //                       Row(
// //                         children: [
// //                           Expanded(
// //                             child: Container(
// //                               height: 48,
// //                               decoration: BoxDecoration(
// //                                 color: isDarkMode ? const Color(0xFF2D3A35) : Colors.white,
// //                                 borderRadius: BorderRadius.circular(12),
// //                                 border: Border.all(
// //                                   color: isDarkMode ? const Color(0xFF3D4D47) : const Color(0xFFD4E2DE),
// //                                 ),
// //                               ),
// //                               child: Material(
// //                                 color: Colors.transparent,
// //                                 child: InkWell(
// //                                   borderRadius: BorderRadius.circular(12),
// //                                   onTap: () {
// //                                     // Google login
// //                                   },
// //                                   child: Row(
// //                                     mainAxisAlignment: MainAxisAlignment.center,
// //                                     children: [
// //                                       Container(
// //                                         width: 24,
// //                                         height: 24,
// //                                         decoration: BoxDecoration(
// //                                           borderRadius: BorderRadius.circular(2),
// //                                         ),
// //                                         child: const FlutterLogo(
// //                                           size: 20,
// //                                           style: FlutterLogoStyle.horizontal,
// //                                         ),
// //                                       ),
// //                                       const SizedBox(width: 8),
// //                                       Text(
// //                                         'Google',
// //                                         style: TextStyle(
// //                                           fontSize: 14,
// //                                           fontWeight: FontWeight.w600,
// //                                           color: isDarkMode ? Colors.white : Colors.black,
// //                                         ),
// //                                       ),
// //                                     ],
// //                                   ),
// //                                 ),
// //                               ),
// //                             ),
// //                           ),
// //                           const SizedBox(width: 16),
// //                           Expanded(
// //                             child: Container(
// //                               height: 48,
// //                               decoration: BoxDecoration(
// //                                 color: isDarkMode ? const Color(0xFF2D3A35) : Colors.white,
// //                                 borderRadius: BorderRadius.circular(12),
// //                                 border: Border.all(
// //                                   color: isDarkMode ? const Color(0xFF3D4D47) : const Color(0xFFD4E2DE),
// //                                 ),
// //                               ),
// //                               child: Material(
// //                                 color: Colors.transparent,
// //                                 child: InkWell(
// //                                   borderRadius: BorderRadius.circular(12),
// //                                   onTap: () {
// //                                     // Apple login
// //                                   },
// //                                   child: Row(
// //                                     mainAxisAlignment: MainAxisAlignment.center,
// //                                     children: [
// //                                       Icon(
// //                                         Icons.apple,
// //                                         color: isDarkMode ? Colors.white : Colors.black,
// //                                         size: 24,
// //                                       ),
// //                                       const SizedBox(width: 8),
// //                                       Text(
// //                                         'Apple',
// //                                         style: TextStyle(
// //                                           fontSize: 14,
// //                                           fontWeight: FontWeight.w600,
// //                                           color: isDarkMode ? Colors.white : Colors.black,
// //                                         ),
// //                                       ),
// //                                     ],
// //                                   ),
// //                                 ),
// //                               ),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ],
// //                   ),
// //                 ),

// //                 // Footer
// //                 Container(
// //                   padding: const EdgeInsets.all(24),
// //                   child: Text.rich(
// //                     TextSpan(
// //                       text: 'By joining, you agree to our ',
// //                       style: TextStyle(
// //                         fontSize: 12,
// //                         color: const Color(0xFF5C8A7A),
// //                       ),
// //                       children: [
// //                         TextSpan(
// //                           text: 'Terms',
// //                           style: const TextStyle(
// //                             color: Color(0xFF39AC86),
// //                             fontWeight: FontWeight.bold,
// //                             decoration: TextDecoration.underline,
// //                           ),
// //                         ),
// //                         const TextSpan(text: ' and '),
// //                         TextSpan(
// //                           text: 'Privacy Policy',
// //                           style: const TextStyle(
// //                             color: Color(0xFF39AC86),
// //                             fontWeight: FontWeight.bold,
// //                             decoration: TextDecoration.underline,
// //                           ),
// //                         ),
// //                         const TextSpan(text: '.'),
// //                       ],
// //                     ),
// //                     textAlign: TextAlign.center,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// // // ==================== HOME SCREEN ====================
// // // class HomeScreen extends StatelessWidget {
// // //  const HomeScreen({super.key});

// // //  @override
// // //  Widget build(BuildContext context) {
// // //    return Scaffold(
// // //      appBar: AppBar(
// //   //      title: const Text('Harvest Hub'),
// //  //       backgroundColor: const Color(0xFF39AC86),
// //    //   ),
// //   //    body: const Center(
// //      //   child: Column(
// //      //     mainAxisAlignment: MainAxisAlignment.center,
// //       //    children: [
// //       //      Icon(
// // //              Icons.eco,
// //      //         size: 100,
// //          //     color: Color(0xFF39AC86),
// //    //         ),
// //          //   SizedBox(height: 20),
// //         //    Text(
// //         //      'Welcome to Harvest Hub!',
// //         //      style: TextStyle(fontSize: 24),
// //       //      ),
// //       //    ],
// //     //    ),
// //       //),
// //    // );
// //  // }
// // //}
