import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:go_router/go_router.dart";
import "package:intl/intl.dart";
import "package:firebase_core/firebase_core.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "firebase_options.dart";

class AppColors {
  static const Color background = Color(0xFFF6F5FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFECEBF7);
  static const Color border = Color(0xFFDCD9EE);
  static const Color primary = Color(0xFFFF6679);
  static const Color primaryDark = Color(0xFFE94C66);
  static const Color secondary = Color(0xFFFF9570);
  static const Color accent = Color(0xFF8B86A6);
  static const Color success = Color(0xFF48D2A0);
  static const Color danger = Color(0xFFFF7A7A);
  static const Color textPrimary = Color(0xFF2F2A45);
  static const Color textSecondary = Color(0xFF5F5A7A);
  static const Color textMuted = Color(0xFF8F8AAA);
  static const Color chip = Color(0xFFE8E6F9);
  static const Color chipSelected = Color(0xFFFFD6DD);
  static const Color featuredStart = Color(0xFFFF7C90);
  static const Color featuredEnd = Color(0xFFFFB07A);
}

class AppShadows {
  static const soft = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 24,
      offset: Offset(0, 16),
    ),
  ];
}

class AppTypography {
  static TextStyle get brand =>
      GoogleFonts.caveat(fontSize: 32, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static TextStyle get headline =>
      GoogleFonts.quicksand(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static TextStyle get subtitle =>
      GoogleFonts.quicksand(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary);
  static TextStyle get body =>
      GoogleFonts.quicksand(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary, height: 1.6);
  static TextStyle get caption =>
      GoogleFonts.quicksand(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'es_CO';
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await AppStore.instance.init();
  runApp(const MyApp());
}

String formatCurrency(int value) {
  final formatter = NumberFormat.currency(locale: 'es_CO', symbol: '\$ ', decimalDigits: 0);
  return formatter.format(value).replaceAll('\u00A0', ' ').trim();
}

String formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);

DateTime _fromFirestoreDate(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.parse(value);
  if (value is DateTime) return value;
  return DateTime.now();
}

class Equipo {
  final String id;
  final String nombre;
  final String descripcion;
  final int precioDia;
  final String categoria;
  final List<String> imagenes;
  final bool disponible;
  final double rating;
  final int reviews;
  final List<String> tags;

  Equipo({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precioDia,
    required this.categoria,
    required this.imagenes,
    required this.disponible,
    required this.rating,
    required this.reviews,
    required this.tags,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre': nombre,
        'descripcion': descripcion,
        'precioDia': precioDia,
        'categoria': categoria,
        'imagenes': imagenes,
        'disponible': disponible,
        'rating': rating,
        'reviews': reviews,
        'tags': tags,
      };

  factory Equipo.fromMap(Map<String, dynamic> map) => Equipo(
        id: map['id'],
        nombre: map['nombre'],
        descripcion: map['descripcion'],
        precioDia: map['precioDia'],
        categoria: map['categoria'],
        imagenes: List<String>.from(map['imagenes'] ?? const []),
        disponible: map['disponible'] ?? true,
        rating: (map['rating'] ?? 4.8).toDouble(),
        reviews: map['reviews'] ?? 0,
        tags: List<String>.from(map['tags'] ?? const []),
      );
}

class Comentario {
  final String id;
  final String equipoId;
  final String usuarioId;
  final String texto;
  final DateTime createdAt;

  Comentario({
    required this.id,
    required this.equipoId,
    required this.usuarioId,
    required this.texto,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'equipoId': equipoId,
        'usuarioId': usuarioId,
        'texto': texto,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory Comentario.fromMap(Map<String, dynamic> map) => Comentario(
        id: map['id'],
        equipoId: map['equipoId'],
        usuarioId: map['usuarioId'],
        texto: map['texto'],
        createdAt: _fromFirestoreDate(map['createdAt']),
      );
}

class Reserva {
  final String id;
  final String equipoId;
  final String usuarioId;
  final DateTime inicio;
  final DateTime fin;
  final String estado;
  final int totalCOP;

  Reserva({
    required this.id,
    required this.equipoId,
    required this.usuarioId,
    required this.inicio,
    required this.fin,
    required this.estado,
    required this.totalCOP,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'equipoId': equipoId,
        'usuarioId': usuarioId,
        'inicio': Timestamp.fromDate(inicio),
        'fin': Timestamp.fromDate(fin),
        'estado': estado,
        'totalCOP': totalCOP,
      };

  factory Reserva.fromMap(Map<String, dynamic> map) => Reserva(
        id: map['id'],
        equipoId: map['equipoId'],
        usuarioId: map['usuarioId'],
        inicio: _fromFirestoreDate(map['inicio']),
        fin: _fromFirestoreDate(map['fin']),
        estado: map['estado'],
        totalCOP: map['totalCOP'],
      );
}

class AppUser {
  final String uid;
  final String email;
  final String nombre;
  final String rol;

  AppUser({
    required this.uid,
    required this.email,
    required this.nombre,
    required this.rol,
  });

  Map<String, dynamic> toMap() => {'uid': uid, 'email': email, 'nombre': nombre, 'rol': rol};

  factory AppUser.fromMap(Map<String, dynamic> map) => AppUser(
        uid: map['uid'],
        email: map['email'],
        nombre: map['nombre'],
        rol: map['rol'],
      );
}

class AppStore {
  AppStore._();
  static final AppStore instance = AppStore._();

  AppUser? currentUser;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> init() async {
    await _ensureSeed();
  }

  Future<void> _ensureSeed() async {
    final existing = await _db.collection('equipos').limit(1).get();
    if (existing.docs.isEmpty) {
      await _seed();
    }
  }

  Future<void> _seed() async {
    final equipos = [
      Equipo(
        id: _id(),
        nombre: 'Pioneer DJ DDJ-FLX10',
        descripcion:
            'Controlador insignia de 4 canales con soporte Stems, pads RGB y doble USB-C para cambios rapidos.',
        precioDia: 350000,
        categoria: 'controladores',
        imagenes: ['assets/images/consola.jpg'],
        disponible: true,
        rating: 4.9,
        reviews: 162,
        tags: ['4 canales', 'Stems', 'Dual USB'],
      ),
      Equipo(
        id: _id(),
        nombre: 'QSC K12.2 Parlante Activo',
        descripcion: 'Parlante activo de 2000 W con cobertura amplia y presets configurables.',
        precioDia: 220000,
        categoria: 'audio',
        imagenes: ['assets/images/luces.jpg'],
        disponible: true,
        rating: 4.8,
        reviews: 98,
        tags: ['2000 W', 'DSP', 'Road ready'],
      ),
      Equipo(
        id: _id(),
        nombre: 'JBL SRX828SP Subwoofer',
        descripcion: 'Subwoofer activo dual de 18 pulgadas con procesamiento digital integrado.',
        precioDia: 280000,
        categoria: 'audio',
        imagenes: ['assets/images/tarjetas.jpg'],
        disponible: true,
        rating: 4.7,
        reviews: 76,
        tags: ['18"', 'DSP', 'Autocalibracion'],
      ),
      Equipo(
        id: _id(),
        nombre: 'Booth Acrilico LED',
        descripcion: 'Cabina modular con iluminacion RGB direccionable para escenarios y sets hibridos.',
        precioDia: 210000,
        categoria: 'cabinas',
        imagenes: ['assets/images/consola.jpg'],
        disponible: true,
        rating: 4.8,
        reviews: 54,
        tags: ['RGB', 'Modular', 'Plegable'],
      ),
      Equipo(
        id: _id(),
        nombre: 'Workstation Road Ready RRDJ',
        descripcion: 'Flight case con ruedas y altura ajustable para controladores premium.',
        precioDia: 160000,
        categoria: 'infraestructura',
        imagenes: ['assets/images/tarjetas.jpg'],
        disponible: false,
        rating: 4.6,
        reviews: 39,
        tags: ['Plegable', 'Road case', 'Heavy duty'],
      ),
      Equipo(
        id: _id(),
        nombre: 'Cameo PixBar 650 C PRO',
        descripcion: 'Barra pixelable RGBWA para washes creativos con modos DMX avanzados.',
        precioDia: 240000,
        categoria: 'luces',
        imagenes: ['assets/images/luces.jpg'],
        disponible: true,
        rating: 4.9,
        reviews: 112,
        tags: ['Pixel', 'RGBWA', 'Master/Slave'],
      ),
    ];

    final comentarios = [
      Comentario(
        id: _id(),
        equipoId: equipos.first.id,
        usuarioId: 'Crew Medellin',
        texto: 'Lo usamos en un show hibrido y la mezcla de stems fue impecable.',
        createdAt: DateTime(2025, 11, 1, 11, 14),
      ),
      Comentario(
        id: _id(),
        equipoId: equipos[5].id,
        usuarioId: 'Luz y Sonido',
        texto: 'La respuesta del pixel mapping fue perfecta con software DMX.',
        createdAt: DateTime(2025, 11, 2, 5, 34),
      ),
    ];

    final batch = _db.batch();
    for (final equipo in equipos) {
      batch.set(_db.collection('equipos').doc(equipo.id), equipo.toMap());
    }
    for (final comentario in comentarios) {
      batch.set(_db.collection('comentarios').doc(comentario.id), comentario.toMap());
    }
    await batch.commit();
  }

  String _id() => DateTime.now().microsecondsSinceEpoch.toString();

  Future<bool> login(String email, String password) async {
    if (email == 'admin@demo.com' && password == 'admin123') {
      currentUser = AppUser(uid: 'admin', email: email, nombre: 'Aurora Crew', rol: 'admin');
      return true;
    }
    return false;
  }

  Future<void> loginInvitado() async {
    currentUser = AppUser(uid: _id(), email: 'invitado@demo.com', nombre: 'Invitado', rol: 'cliente');
  }

  void logout() {
    currentUser = null;
  }

  Future<List<Equipo>> getEquipos() async {
    final snapshot = await _db.collection('equipos').orderBy('nombre').get();
    return snapshot.docs
        .map((doc) {
          final data = Map<String, dynamic>.from(doc.data());
          data['id'] = doc.id;
          return Equipo.fromMap(data);
        })
        .toList();
  }

  Future<List<Comentario>> getComentarios(String equipoId) async {
    final snapshot = await _db
        .collection('comentarios')
        .where('equipoId', isEqualTo: equipoId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data());
      data['id'] = doc.id;
      return Comentario.fromMap(data);
    }).toList();
  }

  Future<void> addComentario(Comentario comentario) async {
    await _db.collection('comentarios').doc(comentario.id).set(comentario.toMap());
  }

  Future<List<Reserva>> getReservasByUser(String uid) async {
    final snapshot = await _db
        .collection('reservas')
        .where('usuarioId', isEqualTo: uid)
        .orderBy('inicio', descending: true)
        .get();
    return snapshot.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data());
      data['id'] = doc.id;
      return Reserva.fromMap(data);
    }).toList();
  }

  Future<void> addReserva(Reserva reserva) async {
    await _db.collection('reservas').doc(reserva.id).set(reserva.toMap());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, __) => const WelcomeScreen()),
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/registro', builder: (_, __) => const RegistroScreen()),
        GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/detalle/:id', builder: (_, state) => DetailScreen(id: state.pathParameters['id']!)),
        GoRoute(path: '/confirmacion', builder: (_, __) => const ConfirmacionScreen()),
        GoRoute(path: '/mis-reservas', builder: (_, __) => const MisReservasScreen()),
        GoRoute(path: '/foro', builder: (_, __) => const ForoScreen()),
      ],
      redirect: (context, state) {
        final logged = AppStore.instance.currentUser != null;
        final visitingAuth = state.fullPath == '/' || state.fullPath == '/registro' || state.fullPath == '/login';
        if (!logged && !visitingAuth) return '/';
        if (logged && (state.fullPath == '/' || state.fullPath == '/login' || state.fullPath == '/registro')) {
          return '/home';
        }
        return null;
      },
    );

    return MaterialApp.router(
      title: 'AuroraPulse Play',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          secondary: AppColors.secondary,
          onSecondary: Colors.white,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
        ),
        textTheme: GoogleFonts.quicksandTextTheme().apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.textSecondary),
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
          hintStyle: const TextStyle(color: AppColors.textMuted),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            elevation: 0,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.featuredStart, AppColors.featuredEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(60),
                  boxShadow: AppShadows.soft,
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 24),
              Text('AuroraPulse Play', style: AppTypography.brand),
              const SizedBox(height: 8),
              Text(
                'Bienvenido a tu plataforma para reservar audio, luces, cabinas e infraestructura profesional sin complicaciones.',
                textAlign: TextAlign.center,
                style: AppTypography.body,
              ),
              const SizedBox(height: 32),
              const _GuideCard(),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/registro'),
                  child: const Text('Crear cuenta'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Iniciar sesion'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  await AppStore.instance.loginInvitado();
                  if (context.mounted) context.go('/home');
                },
                child: const Text('Ingresar como invitado'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  const _GuideCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text('Guia rapida', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 20),
          Text(
            'Tu centro de reservas en un solo lugar',
            style: GoogleFonts.quicksand(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Text(
            'Selecciona la categoria que necesitas, revisa la ficha tecnica y agenda transporte, montaje y acompanamiento.',
            style: AppTypography.body,
          ),
          const SizedBox(height: 28),
          const _GuideListItem(label: 'Audio profesional'),
          const SizedBox(height: 18),
          const _GuideListItem(label: 'Luces y visuales'),
          const SizedBox(height: 18),
          const _GuideListItem(label: 'Infraestructura'),
        ],
      ),
    );
  }
}

class _GuideListItem extends StatelessWidget {
  final String label;
  const _GuideListItem({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.featuredStart, AppColors.featuredEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: AppShadows.soft,
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 16),
        Text(
          label,
          style: GoogleFonts.quicksand(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
      ],
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => loading = true);
    final ok = await AppStore.instance.login(emailCtrl.text.trim(), passCtrl.text.trim());
    setState(() => loading = false);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credenciales no validas')),
      );
      return;
    }
    if (mounted) context.go('/home');
  }

  Future<void> _enterAsGuest() async {
    await AppStore.instance.loginInvitado();
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => context.go('/'),
                      icon: const Icon(Icons.arrow_back),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.featuredStart, AppColors.featuredEnd],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(48),
                      boxShadow: AppShadows.soft,
                    ),
                    child: const Icon(Icons.lock_outline, color: Colors.white, size: 42),
                  ),
                  const SizedBox(height: 18),
                  Text('Hola de nuevo', style: AppTypography.brand),
                  const SizedBox(height: 8),
                  Text(
                    'Ingresa tus credenciales para seguir gestionando tus reservas.',
                    textAlign: TextAlign.center,
                    style: AppTypography.body,
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: AppShadows.soft,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceMuted,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Text('Uso interno AuroraPulse', style: TextStyle(color: AppColors.accent)),
                          ),
                        ),
                        const SizedBox(height: 18),
                        TextField(
                          controller: emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(labelText: 'Correo'),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: passCtrl,
                          obscureText: true,
                          decoration: const InputDecoration(labelText: 'Contrasena'),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: loading ? null : _login,
                          child: loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Ingresar ahora'),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => context.go('/registro'),
                          child: const Text('Crear cuenta'),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: loading ? null : _enterAsGuest,
                          child: const Text('Entrar como invitado'),
                        ),
                      ],
                    ),
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

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final nombreCtrl = TextEditingController();
  final correoCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  void dispose() {
    nombreCtrl.dispose();
    correoCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => context.go('/'),
                      icon: const Icon(Icons.close),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.featuredStart, AppColors.featuredEnd],
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                      ),
                      borderRadius: BorderRadius.circular(48),
                    ),
                    child: const Icon(Icons.bolt, color: Colors.white, size: 42),
                  ),
                  const SizedBox(height: 16),
                  Text('Configura tu crew', style: AppTypography.brand),
                  const SizedBox(height: 8),
                  Text(
                    'Crea un perfil para reservar, gestionar inventario y coordinar tu equipo tecnico.',
                    textAlign: TextAlign.center,
                    style: AppTypography.body,
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: AppShadows.soft,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: nombreCtrl,
                          decoration: const InputDecoration(labelText: 'Nombre del crew o artista'),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: correoCtrl,
                          decoration: const InputDecoration(labelText: 'Correo principal'),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: passCtrl,
                          obscureText: true,
                          decoration: const InputDecoration(labelText: 'Crea una contrasena'),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => context.go('/home'),
                          child: const Text('Crear cuenta AuroraPulse'),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () => context.go('/'),
                          child: const Text('Ya tengo cuenta'),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () async {
                            await AppStore.instance.loginInvitado();
                            if (mounted) context.go('/home');
                          },
                          child: const Text('Solo quiero explorar por ahora'),
                        ),
                      ],
                    ),
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
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _heroController = PageController(viewportFraction: 0.88);
  final List<String> categorias = const ['todos', 'audio', 'cabinas', 'controladores', 'luces', 'infraestructura'];
  List<Equipo> equipos = [];
  String categoriaSeleccionada = 'todos';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    equipos = await AppStore.instance.getEquipos();
    if (mounted) setState(() => loading = false);
  }

  @override
  void dispose() {
    _heroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = AppStore.instance.currentUser!;
    final destacados = equipos.take(5).toList();
    final filtrados = categoriaSeleccionada == 'todos'
        ? equipos
        : equipos.where((e) => e.categoria == categoriaSeleccionada).toList();

    return Scaffold(
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _GreetingHeader(
                      user: user,
                      onLogout: () {
                        AppStore.instance.logout();
                        context.go('/');
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildFeatured(destacados),
                    const SizedBox(height: 28),
                    _SectionHeader(
                      title: 'Categorias',
                      actionLabel: 'Ver todas',
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    _buildCategorias(),
                    const SizedBox(height: 28),
                    _SectionHeader(
                      title: 'Top del momento',
                      actionLabel: 'Ver catalogo completo',
                      onTap: () {},
                    ),
                    const SizedBox(height: 16),
                    filtrados.isEmpty
                        ? const _EmptyListMessage(text: 'No hay productos en esta categoria.')
                        : SizedBox(
                            height: 220,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: filtrados.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 16),
                              itemBuilder: (context, index) {
                                final equipo = filtrados[index];
                                return _EquipmentCard(
                                  equipo: equipo,
                                  onTap: () => context.go('/detalle/${equipo.id}'),
                                );
                              },
                            ),
                          ),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: AuroraNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) context.go('/mis-reservas');
          if (index == 2) context.go('/foro');
        },
      ),
    );
  }

  Widget _buildFeatured(List<Equipo> destacados) {
    if (destacados.isEmpty) {
      return const _EmptyListMessage(text: 'Sin destacados por ahora.');
    }
    return SizedBox(
      height: 240,
      child: PageView.builder(
        controller: _heroController,
        itemCount: destacados.length,
        itemBuilder: (context, index) {
          final Equipo equipo = destacados[index];
          return Padding(
            padding: EdgeInsets.only(right: index == destacados.length - 1 ? 0 : 12),
            child: _FeaturedCard(
              equipo: equipo,
              onTap: () => context.go('/detalle/${equipo.id}'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategorias() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categorias.map((cat) {
          final selected = cat == categoriaSeleccionada;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _CategoryChip(
              label: cat.toUpperCase(),
              selected: selected,
              onTap: () => setState(() => categoriaSeleccionada = cat),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  const _CircleIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: AppColors.textSecondary),
      style: IconButton.styleFrom(
        backgroundColor: AppColors.surface,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(12),
      ),
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  final AppUser user;
  final VoidCallback onLogout;
  const _GreetingHeader({required this.user, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hola, ${user.nombre}', style: AppTypography.headline),
              const SizedBox(height: 4),
              Text('Gestiona tu set para hoy', style: AppTypography.subtitle),
            ],
          ),
        ),
        Row(
          children: [
            _CircleIconButton(
              icon: Icons.chat_bubble_outline,
              onPressed: () {},
            ),
            const SizedBox(width: 10),
            _CircleIconButton(
              icon: Icons.ios_share_outlined,
              onPressed: () {},
            ),
            const SizedBox(width: 10),
            _CircleIconButton(
              icon: Icons.logout,
              onPressed: onLogout,
            ),
          ],
        ),
      ],
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final Equipo equipo;
  final VoidCallback onTap;
  const _FeaturedCard({required this.equipo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [Color(0xFF3B3F61), Color(0xFF212338)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: AppShadows.soft,
        ),
        child: Stack(
          children: [
            if (equipo.imagenes.isNotEmpty)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Image.asset(
                    equipo.imagenes.first,
                    fit: BoxFit.cover,
                    color: Colors.black.withOpacity(0.35),
                    colorBlendMode: BlendMode.darken,
                    errorBuilder: (_, __, ___) =>
                        Container(color: AppColors.featuredStart.withOpacity(0.2)),
                  ),
                ),
              ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.15), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _HeroPill(
                        label: equipo.categoria.toUpperCase(),
                        icon: Icons.blur_on,
                      ),
                      _HeroPill(
                        label:
                            '${equipo.rating.toStringAsFixed(1)} | ${equipo.reviews} resenas',
                        icon: Icons.star_border_rounded,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    equipo.nombre,
                    style: GoogleFonts.quicksand(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${formatCurrency(equipo.precioDia)} por dia',
                    style: GoogleFonts.quicksand(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 42,
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      child: const Text('Ver detalles'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  final String label;
  final IconData icon;
  const _HeroPill({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _CategoryChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.chipSelected : AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
          boxShadow: selected ? AppShadows.soft : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
              size: 18,
              color: selected ? AppColors.primary : AppColors.accent,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EquipmentCard extends StatelessWidget {
  final Equipo equipo;
  final VoidCallback onTap;
  const _EquipmentCard({required this.equipo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 190,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              child: SizedBox(
                height: 110,
                width: double.infinity,
                child: equipo.imagenes.isNotEmpty
                    ? Image.asset(
                        equipo.imagenes.first,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: AppColors.surfaceMuted, child: const Icon(Icons.image, color: AppColors.textMuted)),
                      )
                    : Container(
                        color: AppColors.surfaceMuted,
                        child: const Icon(Icons.image, color: AppColors.textMuted),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      equipo.nombre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${formatCurrency(equipo.precioDia)} / dia',
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: equipo.tags.take(2).map((tag) => _CardTag(label: tag)).toList(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 18, color: AppColors.secondary),
                        const SizedBox(width: 4),
                        Text(
                          equipo.rating.toStringAsFixed(1),
                          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: 6),
                        Text('(${equipo.reviews})', style: AppTypography.caption),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CardTag extends StatelessWidget {
  final String label;
  const _CardTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(color: AppColors.accent),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onTap;
  const _SectionHeader({required this.title, required this.actionLabel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.quicksand(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        TextButton(onPressed: onTap, child: Text(actionLabel)),
      ],
    );
  }
}

class _EmptyListMessage extends StatelessWidget {
  final String text;
  const _EmptyListMessage({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(text, textAlign: TextAlign.center, style: AppTypography.body),
    );
  }
}
class MisReservasScreen extends StatefulWidget {
  const MisReservasScreen({super.key});

  @override
  State<MisReservasScreen> createState() => _MisReservasScreenState();
}

class _MisReservasScreenState extends State<MisReservasScreen> {
  bool loading = true;
  List<Reserva> reservas = [];
  List<Equipo> equipos = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = AppStore.instance.currentUser;
    if (user == null) {
      if (mounted) context.go('/');
      return;
    }
    reservas = await AppStore.instance.getReservasByUser(user.uid);
    equipos = await AppStore.instance.getEquipos();
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis reservas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : reservas.isEmpty
              ? const Center(child: _EmptyListMessage(text: 'Aun no tienes reservas activas.'))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
                  itemCount: reservas.length,
                  itemBuilder: (context, index) {
                    final reserva = reservas[index];
                    final equipo = equipos.firstWhere((e) => e.id == reserva.equipoId, orElse: () {
                      return Equipo(
                        id: reserva.equipoId,
                        nombre: 'Equipo',
                        descripcion: '',
                        precioDia: 0,
                        categoria: '',
                        imagenes: const [],
                        disponible: false,
                        rating: 0,
                        reviews: 0,
                        tags: const [],
                      );
                    });
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: AppColors.border),
                        boxShadow: AppShadows.soft,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: SizedBox(
                                  height: 72,
                                  width: 72,
                                  child: equipo.imagenes.isNotEmpty
                                      ? Image.asset(
                                          equipo.imagenes.first,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(color: AppColors.surfaceMuted),
                                        )
                                      : Container(color: AppColors.surfaceMuted),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      equipo.nombre,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text('Estado: ${reserva.estado}', style: AppTypography.subtitle),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _InfoColumn(title: 'Desde', value: formatDate(reserva.inicio)),
                              _InfoColumn(title: 'Hasta', value: formatDate(reserva.fin)),
                              _InfoColumn(title: 'Total', value: formatCurrency(reserva.totalCOP), highlight: true),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
      bottomNavigationBar: AuroraNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) context.go('/home');
          if (index == 2) context.go('/foro');
        },
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final String title;
  final String value;
  final bool highlight;
  const _InfoColumn({required this.title, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.caption),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: highlight ? AppColors.primary : AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}









class DetailScreen extends StatefulWidget {
  final String id;
  const DetailScreen({super.key, required this.id});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Equipo? equipo;
  DateTime? fechaInicio;
  DateTime? fechaFin;
  int cantidad = 1;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final equipos = await AppStore.instance.getEquipos();
    equipo = equipos.firstWhere((e) => e.id == widget.id);
    if (mounted) setState(() => loading = false);
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initial = isStart ? (fechaInicio ?? now) : (fechaFin ?? fechaInicio ?? now);
    final firstDate = isStart ? now : (fechaInicio ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(data: Theme.of(context).copyWith(colorScheme: Theme.of(context).colorScheme), child: child!);
      },
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        fechaInicio = picked;
        if (fechaFin != null && fechaFin!.isBefore(picked)) {
          fechaFin = picked;
        }
      } else {
        fechaFin = picked;
      }
    });
  }

  Future<void> _reservar() async {
    if (equipo == null || fechaInicio == null || fechaFin == null) return;
    final user = AppStore.instance.currentUser!;
    final dias = fechaFin!.difference(fechaInicio!).inDays + 1;
    final total = dias * equipo!.precioDia * cantidad;
    final reserva = Reserva(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      equipoId: equipo!.id,
      usuarioId: user.uid,
      inicio: fechaInicio!,
      fin: fechaFin!,
      estado: 'pendiente',
      totalCOP: total,
    );
    await AppStore.instance.addReserva(reserva);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reserva creada')),
    );
    context.go('/confirmacion');
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final e = equipo!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: AppColors.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // FOTO / HERO
            _DetailHeroImage(equipo: e),

            // CONTENIDO SCROLLEABLE
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 120), // deja espacio para el botón inferior
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    // CARD PRINCIPAL
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: AppShadows.soft,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _StatusChip(
                                label: e.disponible ? 'Disponible' : 'No disponible',
                                color: e.disponible ? AppColors.success : AppColors.danger,
                                background: e.disponible
                                    ? AppColors.success.withOpacity(0.12)
                                    : AppColors.danger.withOpacity(0.12),
                              ),
                              _StatusChip(
                                label: '${e.rating.toStringAsFixed(1)} | ${e.reviews} resenas',
                                color: AppColors.accent,
                                background: AppColors.surfaceMuted,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(e.nombre, style: AppTypography.headline),
                          const SizedBox(height: 8),
                          Text('${formatCurrency(e.precioDia)} por dia', style: AppTypography.subtitle),
                          const SizedBox(height: 16),
                          Text(e.descripcion, style: AppTypography.body),
                          const SizedBox(height: 20),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: e.tags
                                .map((tag) => Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: AppColors.chip,
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      child: Text(tag, style: AppTypography.caption),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),
                    // CARD RESERVA
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: AppShadows.soft,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Reserva tu periodo',
                              style: GoogleFonts.quicksand(fontSize: 18, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          Text(
                            'Selecciona fechas para estimar el total. Precio base: ${formatCurrency(e.precioDia)} por dia.',
                            style: AppTypography.body,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _DateSelector(
                                  label: 'Inicio',
                                  value: fechaInicio == null ? 'Seleccionar' : formatDate(fechaInicio!),
                                  onTap: () => _pickDate(isStart: true),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _DateSelector(
                                  label: 'Fin',
                                  value: fechaFin == null ? 'Seleccionar' : formatDate(fechaFin!),
                                  onTap: fechaInicio == null ? null : () => _pickDate(isStart: false),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Text('Cantidad',
                                  style: GoogleFonts.quicksand(
                                      fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                              const SizedBox(width: 12),
                              _QuantitySelector(
                                value: cantidad,
                                onChanged: (value) => setState(() => cantidad = value),
                              ),
                              const Spacer(),
                              Text(
                                'Subtotal: ${formatCurrency(e.precioDia * cantidad)}',
                                style: GoogleFonts.quicksand(
                                    fontWeight: FontWeight.w600, color: AppColors.primaryDark),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),
                    const _AuroraSectionHeading(title: 'Specs destacadas'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _DetailInfoCard(
                            icon: Icons.bolt_outlined,
                            title: 'Tecnologia',
                            description: 'Compatibilidad Rekordbox y Serato con modo stems.',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _DetailInfoCard(
                            icon: Icons.settings_input_component,
                            title: 'Conectividad',
                            description: '4 canales, 2x USB-C y salidas balanceadas XLR.',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    const _AuroraSectionHeading(title: 'Recordatorios de logistica'),
                    const SizedBox(height: 16),
                    const _DetailLogisticsCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ✅ Botón inferior correcto (sin AuroraNavBar en esta pantalla)
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (fechaInicio != null && fechaFin != null) ? _reservar : null,
              child: Text('Confirmar reserva por ${formatCurrency(e.precioDia * cantidad)}'),
            ),
          ),
        ),
      ),
    );
  }
}





























class _DetailHeroImage extends StatelessWidget {
  final Equipo equipo;
  const _DetailHeroImage({required this.equipo});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Stack(
        children: [
          Positioned.fill(
            child: equipo.imagenes.isNotEmpty
                ? Image.asset(
                    equipo.imagenes.first,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: AppColors.surfaceMuted),
                  )
                : Container(color: AppColors.surfaceMuted),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.35), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    equipo.categoria.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  equipo.nombre,
                  style: GoogleFonts.quicksand(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    shadows: const [Shadow(color: Colors.black54, blurRadius: 6)],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      '${formatCurrency(equipo.precioDia)} por dia',
                      style: GoogleFonts.quicksand(color: Colors.white70, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.star_rounded, size: 18, color: AppColors.secondary),
                    const SizedBox(width: 4),
                    Text(
                      '${equipo.rating.toStringAsFixed(1)} (${equipo.reviews})',
                      style: GoogleFonts.quicksand(color: Colors.white70, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;
  const _DateSelector({required this.label, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTypography.caption),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: onTap == null ? AppColors.textMuted : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _QuantitySelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: value > 1 ? () => onChanged(value - 1) : null,
          ),
          Text('$value', style: const TextStyle(fontWeight: FontWeight.w700)),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: value < 10 ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;
  const _StatusChip({required this.label, required this.color, required this.background});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        label,
        style: GoogleFonts.quicksand(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AuroraSectionHeading extends StatelessWidget {
  final String title;
  const _AuroraSectionHeading({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.quicksand(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
    );
  }
}

class _DetailInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  const _DetailInfoCard({required this.icon, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.quicksand(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(description, style: AppTypography.body),
        ],
      ),
    );
  }
}

class _DetailLogisticsCard extends StatelessWidget {
  const _DetailLogisticsCard();

  @override
  Widget build(BuildContext context) {
    const items = [
      _LogisticsRow(
        icon: Icons.inbox_outlined,
        title: 'Incluye',
        description: 'Cableado de poder, flight case y soporte tecnico en sitio.',
      ),
      _LogisticsRow(
        icon: Icons.access_time,
        title: 'Ventana de montaje',
        description: 'Dos horas antes del evento (puede ampliarse segun disponibilidad).',
      ),
      _LogisticsRow(
        icon: Icons.local_shipping_outlined,
        title: 'Cobertura',
        description: 'Envigado, Medellin e Itagui con costo de transporte adicional.',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(items[i].icon, color: AppColors.accent),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        items[i].title,
                        style: GoogleFonts.quicksand(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(items[i].description, style: AppTypography.body),
                    ],
                  ),
                ),
              ],
            ),
            if (i != items.length - 1) ...[
              const SizedBox(height: 16),
              const Divider(color: AppColors.border),
              const SizedBox(height: 16),
            ],
          ],
          const SizedBox(height: 20),
          TextButton(
            onPressed: () {},
            child: const Text('Ver experiencias de otros crews en la comunidad'),
          ),
        ],
      ),
    );
  }
}

class _LogisticsRow {
  final IconData icon;
  final String title;
  final String description;
  const _LogisticsRow({required this.icon, required this.title, required this.description});
}

class ConfirmacionScreen extends StatelessWidget {
  const ConfirmacionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => context.go('/home'),
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(height: 16),
              Text('Reserva confirmada', style: AppTypography.headline),
              const SizedBox(height: 8),
              Text(
                'Tu solicitud fue enviada. Nuestro equipo revisara disponibilidad y se comunicara contigo.',
                style: AppTypography.body,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: AppShadows.soft,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _InfoColumn(title: 'Estado', value: 'Pendiente de confirmacion'),
                    SizedBox(height: 12),
                    _InfoColumn(title: 'Revisa tus reservas', value: 'Panel -> Reservas'),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.go('/mis-reservas'),
                child: const Text('Ir a mis reservas'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ForoScreen extends StatefulWidget {
  const ForoScreen({super.key});

  @override
  State<ForoScreen> createState() => _ForoScreenState();
}

class _ForoScreenState extends State<ForoScreen> {
  final TextEditingController textoCtrl = TextEditingController();
  List<Equipo> equipos = [];
  List<Comentario> comentarios = [];
  String? equipoSeleccionado;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    equipos = await AppStore.instance.getEquipos();
    if (equipos.isNotEmpty) {
      equipoSeleccionado = equipos.first.id;
      comentarios = await AppStore.instance.getComentarios(equipoSeleccionado!);
    }
    if (mounted) setState(() => loading = false);
  }

  Future<void> _changeEquipo(String id) async {
    equipoSeleccionado = id;
    comentarios = await AppStore.instance.getComentarios(id);
    if (mounted) setState(() {});
  }

  Future<void> _send() async {
    if (textoCtrl.text.trim().isEmpty || equipoSeleccionado == null) return;
    final user = AppStore.instance.currentUser!;
    final comentario = Comentario(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      equipoId: equipoSeleccionado!,
      usuarioId: user.nombre,
      texto: textoCtrl.text.trim(),
      createdAt: DateTime.now(),
    );
    await AppStore.instance.addComentario(comentario);
    textoCtrl.clear();
    await _changeEquipo(equipoSeleccionado!);
  }

  @override
  void dispose() {
    textoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comunidad'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Comparte feedback o escenas', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: DropdownButton<String>(
                          value: equipoSeleccionado,
                          isExpanded: true,
                          underline: const SizedBox.shrink(),
                          borderRadius: BorderRadius.circular(16),
                          items: equipos
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e.id,
                                  child: Text(e.nombre),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              _changeEquipo(value);
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: textoCtrl,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Describe tu montaje, escenas o notas clave',
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _send,
                        child: const Text('Compartir al foro'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: comentarios.isEmpty
                      ? const Center(child: _EmptyListMessage(text: 'Aun no hay comentarios.'))
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                          itemCount: comentarios.length,
                          itemBuilder: (context, index) {
                            final comentario = comentarios[index];
                            final equipo = equipos.firstWhere((e) => e.id == comentario.equipoId, orElse: () {
                              return Equipo(
                                id: comentario.equipoId,
                                nombre: 'Equipo',
                                descripcion: '',
                                precioDia: 0,
                                categoria: '',
                                imagenes: const [],
                                disponible: false,
                                rating: 0,
                                reviews: 0,
                                tags: const [],
                              );
                            });
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(equipo.nombre, style: const TextStyle(fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 8),
                                  Text(comentario.texto, style: AppTypography.body),
                                  const SizedBox(height: 12),
                                  Text(
                                    '${comentario.usuarioId} - ${DateFormat('dd MMM yyyy - HH:mm').format(comentario.createdAt)}',
                                    style: AppTypography.caption,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      bottomNavigationBar: AuroraNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) context.go('/home');
          if (index == 1) context.go('/mis-reservas');
        },
      ),
    );
  }
}

class AuroraNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const AuroraNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: AppShadows.soft,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textMuted,
            selectedIconTheme: const IconThemeData(color: AppColors.primary),
            unselectedIconTheme: const IconThemeData(color: AppColors.textMuted),
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
            currentIndex: currentIndex,
            onTap: onTap,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Panel'),
              BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: 'Reservas'),
              BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Comunidad'),
            ],
          ),
        ),
      ),
    );
  }
}
