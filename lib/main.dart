import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppColors {
  static const Color background = Color(0xFF0F172A);
  static const Color surface = Color(0xFF1E293B);
  static const Color surfaceMuted = Color(0xFF273449);
  static const Color border = Color(0xFF334155);
  static const Color primary = Color(0xFF4C6EF5);
  static const Color secondary = Color(0xFF38BDF8);
  static const Color success = Color(0xFF34D399);
  static const Color danger = Color(0xFFF87171);
  static const Color textPrimary = Color(0xFFE2E8F0);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppStore.instance.init();
  runApp(const MyApp());
}

/// -------------------- DATA MODELS --------------------
class Equipo {
  String id;
  String nombre;
  String descripcion;
  int precioDia;
  String categoria;
  List<String> imagenes;
  bool disponible;

  Equipo({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precioDia,
    required this.categoria,
    required this.imagenes,
    required this.disponible,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'nombre': nombre,
    'descripcion': descripcion,
    'precioDia': precioDia,
    'categoria': categoria,
    'imagenes': imagenes,
    'disponible': disponible,
  };

  factory Equipo.fromMap(Map<String, dynamic> m) => Equipo(
    id: m['id'],
    nombre: m['nombre'],
    descripcion: m['descripcion'],
    precioDia: m['precioDia'],
    categoria: m['categoria'],
    imagenes: List<String>.from(m['imagenes'] ?? []),
    disponible: m['disponible'] ?? true,
  );
}

class Comentario {
  String id;
  String equipoId;
  String usuarioId;
  String texto;
  DateTime createdAt;
  Comentario({required this.id, required this.equipoId, required this.usuarioId, required this.texto, required this.createdAt});

  Map<String, dynamic> toMap() => {
    'id': id,
    'equipoId': equipoId,
    'usuarioId': usuarioId,
    'texto': texto,
    'createdAt': createdAt.toIso8601String(),
  };
  factory Comentario.fromMap(Map<String, dynamic> m) => Comentario(
    id: m['id'],
    equipoId: m['equipoId'],
    usuarioId: m['usuarioId'],
    texto: m['texto'],
    createdAt: DateTime.parse(m['createdAt']),
  );
}

class Reserva {
  String id;
  String equipoId;
  String usuarioId;
  DateTime inicio;
  DateTime fin;
  String estado;
  int totalCOP;

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
    'inicio': inicio.toIso8601String(),
    'fin': fin.toIso8601String(),
    'estado': estado,
    'totalCOP': totalCOP,
  };
  factory Reserva.fromMap(Map<String, dynamic> m) => Reserva(
    id: m['id'],
    equipoId: m['equipoId'],
    usuarioId: m['usuarioId'],
    inicio: DateTime.parse(m['inicio']),
    fin: DateTime.parse(m['fin']),
    estado: m['estado'],
    totalCOP: m['totalCOP'],
  );
}

class AppUser {
  String uid;
  String email;
  String nombre;
  String rol;
  AppUser({required this.uid, required this.email, required this.nombre, required this.rol});

  Map<String, dynamic> toMap() => {'uid': uid, 'email': email, 'nombre': nombre, 'rol': rol};
  factory AppUser.fromMap(Map<String, dynamic> m) => AppUser(uid: m['uid'], email: m['email'], nombre: m['nombre'], rol: m['rol']);
}

/// -------------------- STORE --------------------
class AppStore {
  static final AppStore instance = AppStore._();
  AppStore._();
  SharedPreferences? _prefs;
  AppUser? currentUser;

Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    if (true) {
      await _seed();
      await _prefs!.setBool('seeded', true);
    }
  }
Future<void> _seed() async {
    print("🔴 INICIANDO SEED");

 final equipos = [
  Equipo(id: _id(), nombre: 'Consola dj', descripcion: 'dispositivo electrónico diseñado principalmente para jugar videojuegos, aunque también puede tener otras funciones como reproducir contenido multimedia o acceder a servicios en línea', precioDia: 40, categoria: 'consolas', imagenes: ['assets/images/consola.jpg'], disponible: true),
  Equipo(id: _id(), nombre: 'Tarjetas DJ', descripcion: 'Tarjetas profesionales para control de audio', precioDia: 30, categoria: 'tarimas', imagenes: ['assets/images/tarjetas.jpg'], disponible: true),
  Equipo(id: _id(), nombre: 'Luces RGB', descripcion: 'Sistema de iluminación profesional', precioDia: 25, categoria: 'luces', imagenes: ['assets/images/luces.jpg'], disponible: false),
];
    print("🔴 EQUIPOS CREADOS: ${equipos[0].imagenes[0]}");

    await _saveList('equipos', equipos.map((e) => e.toMap()).toList());
    await _saveList('comentarios', []);
    await _saveList('reservas', []);
  }

  String _id() => DateTime.now().microsecondsSinceEpoch.toString();
  Future<void> _saveList(String key, List<Map<String, dynamic>> list) async => _prefs!.setString(key, jsonEncode(list));
  List<Map<String, dynamic>> _getList(String key) {
    final s = _prefs!.getString(key);
    if (s == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(s));
  }

  Future<bool> login(String email, String password) async {
    if (email == 'admin@demo.com' && password == 'admin123') {
      currentUser = AppUser(uid: 'admin', email: email, nombre: 'Seun', rol: 'admin');
      return true;
    }
    return false;
  }
  
  Future<void> loginInvitado() async {
    currentUser = AppUser(uid: _id(), email: 'invitado@demo.com', nombre: 'Seun', rol: 'cliente');
  }
  
  void logout() { currentUser = null; }

  Future<List<Equipo>> getEquipos() async => _getList('equipos').map(Equipo.fromMap).toList();
  
  Future<List<Comentario>> getComentarios(String equipoId) async {
    final all = _getList('comentarios').map(Comentario.fromMap).toList();
    return all.where((c)=>c.equipoId==equipoId).toList();
  }
  
  Future<void> addComentario(Comentario c) async {
    final list = _getList('comentarios'); list.add(c.toMap()); await _saveList('comentarios', list);
  }

  Future<List<Reserva>> getReservasByUser(String uid) async {
    return _getList('reservas').map(Reserva.fromMap).where((r)=>r.usuarioId==uid).toList();
  }

  Future<void> addReserva(Reserva r) async {
    final list = _getList('reservas'); list.add(r.toMap()); await _saveList('reservas', list);
  }
}

/// -------------------- APP --------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/registro', builder: (_, __) => const RegistroScreen()),
        GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/detalle/:id', builder: (_, s) => DetailScreen(id: s.pathParameters['id']!)),
        GoRoute(path: '/confirmacion', builder: (_, __) => const ConfirmacionScreen()),
        GoRoute(path: '/mis-reservas', builder: (_, __) => const MisReservasScreen()),
        GoRoute(path: '/foro', builder: (_, __) => const ForoScreen()),
      ],
      redirect: (ctx, st) {
        final logged = AppStore.instance.currentUser != null;
        if (!logged && st.fullPath != '/' && st.fullPath != '/registro') return '/';
        return null;
      },
    );
    return MaterialApp.router(
      title: 'DJ Alquiler',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: AppColors.primary,
          onPrimary: AppColors.textPrimary,
          secondary: AppColors.secondary,
          onSecondary: AppColors.textPrimary,
          error: AppColors.danger,
          onError: AppColors.textPrimary,
          background: AppColors.background,
          onBackground: AppColors.textPrimary,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
        ),
        textTheme: ThemeData.dark().textTheme.apply(
              bodyColor: AppColors.textPrimary,
              displayColor: AppColors.textPrimary,
            ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: AppColors.textPrimary),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          hintStyle: TextStyle(color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.surface,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.border),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.danger),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textPrimary,
            textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: AppColors.secondary),
        ),
        cardColor: AppColors.surface,
        dividerColor: AppColors.border,
      ),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

/// -------------------- LOGIN --------------------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 24, offset: Offset(0, 12)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'DJ ALQUILER',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Bienvenido de nuevo, ingresa tus datos para continuar',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Correo electrónico'),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: passCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    final ok = await AppStore.instance.login(emailCtrl.text.trim(), passCtrl.text.trim());
                    if (!ok) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Credenciales inválidas'),
                          backgroundColor: AppColors.danger,
                        ),
                      );
                      return;
                    }
                    if (context.mounted) context.go('/home');
                  },
                  child: const Text('Iniciar sesión'),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => context.go('/registro'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.secondary,
                    side: const BorderSide(color: AppColors.secondary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Crear una cuenta'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () async {
                    await AppStore.instance.loginInvitado();
                    if (context.mounted) context.go('/home');
                  },
                  child: const Text('Entrar como invitado'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// -------------------- REGISTRO --------------------
class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});
  @override State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final nombreCtrl = TextEditingController();
  final apellidosCtrl = TextEditingController();
  final correoCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Stack(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 24, offset: Offset(0, 12)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Crear cuenta',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Completa tus datos para solicitar equipos de sonido y luces',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 28),
                    TextField(
                      controller: nombreCtrl,
                      decoration: const InputDecoration(labelText: 'Nombres'),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: apellidosCtrl,
                      decoration: const InputDecoration(labelText: 'Apellidos'),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: correoCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Correo electrónico'),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: passCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Contraseña'),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () => context.go('/home'),
                      child: const Text('Registrarme'),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => context.go('/'),
                      child: const Text('Volver a iniciar sesión'),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => context.go('/'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// -------------------- HOME --------------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Equipo> equipos = [];
  String categoriaSeleccionada = 'consolas';
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

Future<void> _load() async {
  equipos = await AppStore.instance.getEquipos();
  print("🟢 EQUIPOS CARGADOS EN HOME: ${equipos.length}");
  if (equipos.isNotEmpty) {
    print("🟢 PRIMER EQUIPO: ${equipos[0].nombre}");
    print("🟢 IMAGEN PRIMER EQUIPO: ${equipos[0].imagenes.isNotEmpty ? equipos[0].imagenes[0] : 'VACIO'}");
  }
  setState(() {});
}

  @override
  Widget build(BuildContext context) {
    final user = AppStore.instance.currentUser!;
    final equiposFiltrados = equipos.where((e) => e.categoria == categoriaSeleccionada).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textSecondary),
            onPressed: () {
              AppStore.instance.logout();
              context.go('/');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hola, ${user.nombre}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Explora el catálogo de equipos profesionales',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                ],
              ),
            ),
            Container(
              height: 220,
              margin: EdgeInsets.only(bottom: 20),
              child: PageView.builder(
                itemCount: equipos.length,
                itemBuilder: (_, i) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: equipos[i].imagenes.isNotEmpty
                        ? Image.asset(
                            equipos[i].imagenes[0],
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(color: AppColors.surfaceMuted),
                          )
                        : Container(color: AppColors.surfaceMuted),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildTab('consolas'),
                  _buildTab('tarimas'),
                  _buildTab('luces'),
                ],
              ),
            ),
            SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, 
                  crossAxisSpacing: 12, 
                  mainAxisSpacing: 12, 
                  childAspectRatio: 0.95
                ),
                itemCount: equiposFiltrados.length >= 2 ? 4 : equiposFiltrados.length,
                itemBuilder: (_, i) {
                  final equipo = equiposFiltrados[i % equiposFiltrados.length];
                  return GestureDetector(
                    onTap: () => context.go('/detalle/${equipo.id}'),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              child: equipo.imagenes.isNotEmpty
                                  ? Image.asset(
                                      equipo.imagenes[0],
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(color: AppColors.surfaceMuted),
                                    )
                                  : Container(color: AppColors.surfaceMuted),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  equipo.nombre,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  equipo.categoria.toUpperCase(),
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '\$${equipo.precioDia}/día',
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: equipo.disponible ? AppColors.success.withOpacity(0.1) : AppColors.danger.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        equipo.disponible ? 'Disponible' : 'No disponible',
                                        style: TextStyle(
                                          color: equipo.disponible ? AppColors.success : AppColors.danger,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        currentIndex: _selectedIndex,
        onTap: (i) {
          setState(() => _selectedIndex = i);
          if (i == 0) {}
          if (i == 1) context.go('/mis-reservas');
          if (i == 2) context.go('/foro');
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.event_note), label: 'Mis Reservas'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'foro'),
        ],
      ),
    );
  }

  Widget _buildTab(String cat) {
    final isSelected = cat == categoriaSeleccionada;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => categoriaSeleccionada = cat),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surfaceMuted : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
          ),
          child: Text(
            cat,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

/// -------------------- MIS RESERVAS --------------------
class MisReservasScreen extends StatefulWidget {
  const MisReservasScreen({super.key});
  @override State<MisReservasScreen> createState() => _MisReservasScreenState();
}

class _MisReservasScreenState extends State<MisReservasScreen> {
  List<Reserva> reservas = [];
  List<Equipo> equipos = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = AppStore.instance.currentUser!;
    reservas = await AppStore.instance.getReservasByUser(user.uid);
    equipos = await AppStore.instance.getEquipos();
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Mis Reservas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : reservas.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.event_busy, size: 64, color: AppColors.textMuted),
                      SizedBox(height: 16),
                      Text('No tienes reservas', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(20),
                  itemCount: reservas.length,
                  itemBuilder: (_, i) {
                    final r = reservas[i];
                    final equipo = equipos.firstWhere((e) => e.id == r.equipoId, orElse: () => Equipo(id: '', nombre: 'Equipo', descripcion: '', precioDia: 0, categoria: '', imagenes: [], disponible: false));
                    return Container(
                      margin: EdgeInsets.only(bottom: 16),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: equipo.imagenes.isNotEmpty
                                    ? Image.asset(
                                        equipo.imagenes[0],
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(width: 60, height: 60, color: AppColors.surfaceMuted),
                                      )
                                    : Container(width: 60, height: 60, color: AppColors.surfaceMuted),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      equipo.nombre,
                                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Estado: ${r.estado}',
                                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          const Divider(color: AppColors.border, height: 1),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Desde', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                  Text(DateFormat('dd/MM/yyyy').format(r.inicio), style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                                ],
                              ),
                              const Icon(Icons.arrow_forward, color: AppColors.textMuted, size: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Hasta', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                  Text(DateFormat('dd/MM/yyyy').format(r.fin), style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('Total', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                  Text('\$${r.totalCOP}', style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        currentIndex: 1,
        onTap: (i) {
          if (i == 0) context.go('/home');
          if (i == 2) context.go('/foro');
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.event_note), label: 'Mis Reservas'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'foro'),
        ],
      ),
    );
  }
}

/// -------------------- DETALLE --------------------
class DetailScreen extends StatefulWidget {
  final String id;
  const DetailScreen({super.key, required this.id});
  @override State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Equipo? equipo;
  double cantidadNecesita = 1;
  DateTime? fechaInicio;
  DateTime? fechaFin;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await AppStore.instance.getEquipos();
    equipo = list.firstWhere((e) => e.id == widget.id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (equipo == null) return Scaffold(body: Center(child: CircularProgressIndicator()));
    final e = equipo!;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 280,
                    width: double.infinity,
                    child: e.imagenes.isNotEmpty
                        ? Image.asset(
                            e.imagenes[0],
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(color: AppColors.surfaceMuted),
                          )
                        : Container(color: AppColors.surfaceMuted),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 28),
                        onPressed: () => context.go('/home'),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.surface.withOpacity(0.5),
                          shape: const CircleBorder(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              e.nombre,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Text('4K', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        e.disponible ? 'Disponible' : 'No disponible',
                        style: TextStyle(
                          color: e.disponible ? AppColors.success : AppColors.danger,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Cantidad disponible: 10 unidades', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                      const SizedBox(height: 24),
                      const Text('Fechas de reserva', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context, 
                                  initialDate: DateTime.now(), 
                                  firstDate: DateTime.now(), 
                                  lastDate: DateTime.now().add(Duration(days: 365)),
                                  builder: (context, child) {
                                    return Theme(data: ThemeData.dark(), child: child!);
                                  },
                                );
                                if (picked != null) setState(() => fechaInicio = picked);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Text(
                                  fechaInicio == null ? 'Fecha inicio' : DateFormat('dd/MM/yyyy').format(fechaInicio!),
                                  style: TextStyle(color: fechaInicio == null ? AppColors.textMuted : AppColors.textPrimary),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context, 
                                  initialDate: fechaInicio ?? DateTime.now(), 
                                  firstDate: fechaInicio ?? DateTime.now(), 
                                  lastDate: DateTime.now().add(Duration(days: 365)),
                                  builder: (context, child) {
                                    return Theme(data: ThemeData.dark(), child: child!);
                                  },
                                );
                                if (picked != null) setState(() => fechaFin = picked);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Text(
                                  fechaFin == null ? 'Fecha fin' : DateFormat('dd/MM/yyyy').format(fechaFin!),
                                  style: TextStyle(color: fechaFin == null ? AppColors.textMuted : AppColors.textPrimary),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      const Text('Cantidad que necesitas', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppColors.primary,
                          inactiveTrackColor: AppColors.border,
                          thumbColor: AppColors.primary,
                          overlayColor: AppColors.primary.withOpacity(0.2),
                          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
                          trackHeight: 3,
                        ),
                        child: Slider(
                          value: cantidadNecesita,
                          min: 1,
                          max: 10,
                          divisions: 9,
                          label: cantidadNecesita.toInt().toString(),
                          onChanged: (v) => setState(() => cantidadNecesita = v),
                        ),
                      ),
                      Text('${cantidadNecesita.toInt()} unidades', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      const SizedBox(height: 24),
                      const Text('Descripción', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.3)),
                      const SizedBox(height: 12),
                      Text(e.descripcion, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.6, letterSpacing: 0.2)),
                      SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 80,
            left: 20,
            right: 20,
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: (fechaInicio != null && fechaFin != null)
                    ? () async {
                      final user = AppStore.instance.currentUser!;
                      final dias = fechaFin!.difference(fechaInicio!).inDays + 1;
                      final total = dias * e.precioDia * cantidadNecesita.toInt();
                  final r = Reserva(
                    id: DateTime.now().microsecondsSinceEpoch.toString(),
                    equipoId: e.id,
                    usuarioId: user.uid,
                    inicio: fechaInicio!,
                    fin: fechaFin!,
                    estado: 'pendiente',
                    totalCOP: total,
                  );
                      await AppStore.instance.addReserva(r);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Reserva creada')),
                        );
                        context.go('/confirmacion');
                      }
                    }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Reservar', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        currentIndex: 0,
        onTap: (i) {
          if (i == 0) context.go('/home');
          if (i == 1) context.go('/mis-reservas');
          if (i == 2) context.go('/foro');
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.event_note), label: 'Mis Reservas'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'foro'),
        ],
      ),
    );
  }
}

/// -------------------- CONFIRMACION --------------------
class ConfirmacionScreen extends StatelessWidget {
  const ConfirmacionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
              onPressed: () => context.go('/home'),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Fecha de la reserva', style: TextStyle(color: AppColors.textSecondary)),
                          const Text('Fecha de entrega', style: TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 32),
                  const Text('Resumen de la reserva', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  const Text('Nombre del usuario', style: TextStyle(color: AppColors.textSecondary)),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
                    child: const Text('Seun', style: TextStyle(color: AppColors.textPrimary)),
                  ),
                  SizedBox(height: 16),
                  const Text('Cantidad', style: TextStyle(color: AppColors.textSecondary)),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
                    child: const Text('1', style: TextStyle(color: AppColors.textPrimary)),
                  ),
                  SizedBox(height: 16),
                  const Text('Precio unitario', style: TextStyle(color: AppColors.textSecondary)),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
                    child: const Text('\$40', style: TextStyle(color: AppColors.textPrimary)),
                  ),
                  SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Valor total de reserva', style: TextStyle(color: AppColors.textSecondary)),
                      const Text('\$40.00', style: TextStyle(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => context.go('/home'),
                      child: const Text('Confirmar reserva', style: TextStyle(fontSize: 16)),
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

/// -------------------- FORO --------------------
class ForoScreen extends StatefulWidget {
  const ForoScreen({super.key});
  @override State<ForoScreen> createState() => _ForoScreenState();
}

class _ForoScreenState extends State<ForoScreen> {
  final txtCtrl = TextEditingController();
  List<Comentario> comentarios = [];
  List<Equipo> equipos = [];
  String? equipoSeleccionadoId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    equipos = await AppStore.instance.getEquipos();
    if (equipos.isNotEmpty) {
      equipoSeleccionadoId = equipos.first.id;
      comentarios = await AppStore.instance.getComentarios(equipoSeleccionadoId!);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = AppStore.instance.currentUser!;
    final equipoActual = equipos.isNotEmpty && equipoSeleccionadoId != null
        ? equipos.firstWhere((e) => e.id == equipoSeleccionadoId)
        : null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Foro'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (equipos.isNotEmpty)
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Selecciona un producto', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButton<String>(
                      value: equipoSeleccionadoId,
                      isExpanded: true,
                      underline: const SizedBox(),
                      dropdownColor: AppColors.surface,
                      style: const TextStyle(color: AppColors.textPrimary),
                      items: equipos.map((e) {
                        return DropdownMenuItem(
                          value: e.id,
                          child: Text(e.nombre),
                        );
                      }).toList(),
                      onChanged: (val) async {
                        setState(() => equipoSeleccionadoId = val);
                        comentarios = await AppStore.instance.getComentarios(val!);
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
            ),
          if (equipoActual != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Escribe tu comentario sobre ${equipoActual.nombre}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  SizedBox(height: 8),
                  Container(
                    height: 120,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextField(
                      controller: txtCtrl,
                      maxLines: 5,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Tu opinión sobre este producto...',
                        hintStyle: const TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (txtCtrl.text.trim().isNotEmpty && equipoSeleccionadoId != null) {
                          final c = Comentario(
                            id: DateTime.now().toString(),
                            equipoId: equipoSeleccionadoId!,
                            usuarioId: user.uid,
                            texto: txtCtrl.text.trim(),
                            createdAt: DateTime.now(),
                          );
                          await AppStore.instance.addComentario(c);
                          comentarios = await AppStore.instance.getComentarios(equipoSeleccionadoId!);
                          txtCtrl.clear();
                          setState(() {});
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Enviar comentario', style: TextStyle(fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const Text('Comentarios', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
          ),
          SizedBox(height: 12),
          Expanded(
            child: comentarios.isEmpty
                ? Center(
                    child: const Text('No hay comentarios aún', style: TextStyle(color: AppColors.textMuted)),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: comentarios.length,
                    itemBuilder: (_, i) {
                      final c = comentarios[i];
                      final equipo = equipos.firstWhere((e) => e.id == c.equipoId, orElse: () => Equipo(id: '', nombre: 'Producto', descripcion: '', precioDia: 0, categoria: '', imagenes: [], disponible: false));
                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: equipo.imagenes.isNotEmpty
                                  ? Image.asset(
                                      equipo.imagenes[0],
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(width: 50, height: 50, color: AppColors.surfaceMuted),
                                    )
                                  : Container(width: 50, height: 50, color: AppColors.surfaceMuted),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    equipo.nombre,
                                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(height: 6),
                                  Text(c.texto, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4)),
                                  SizedBox(height: 6),
                                  Text(
                                    '${c.usuarioId} • ${DateFormat('dd/MM/yyyy HH:mm').format(c.createdAt)}',
                                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        currentIndex: 2,
        onTap: (i) {
          if (i == 0) context.go('/home');
          if (i == 1) context.go('/mis-reservas');
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.event_note), label: 'Mis Reservas'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'foro'),
        ],
      ),
    );
  }
}