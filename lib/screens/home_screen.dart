import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:microguard/models/registro_cuenta.dart';
import '../services/auth_service.dart';
import '../models/usuario.dart';
import '../models/producto_mas_vendido.dart';
import '../utils/app_theme.dart';
import '../widgets/stat_card.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  RegistroCuenta? _usuario;
  bool _isLoading = true;
  int _selectedIndex = 0;

  // Datos de ejemplo - luego los obtendrás de tu API
  final List<ProductoMasVendido> _productosMasVendidos = [
    ProductoMasVendido(
      nombre: 'Inka kola 500ml',
      unidades: 120,
      precio: 4.20,
    ),
    ProductoMasVendido(
      nombre: 'Galletas Oreo',
      unidades: 80,
      precio: 3.37,
    ),
    ProductoMasVendido(
      nombre: 'Leche Gloria 1L',
      unidades: 63,
      precio: 3.37,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
  }

  Future<void> _cargarUsuario() async {
    final usuario = await _authService.getUsuario();
    setState(() {
      _usuario = usuario;
      _isLoading = false;
    });
  }

  void _onNavBarTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Aquí implementarás la navegación a otras pantallas
    switch (index) {
      case 0:
      // Ya estamos en Home
        break;
      case 1:
      // Navegar a Estadísticas
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Estadísticas - Próximamente')),
        );
        break;
      case 2:
      // Navegar a Ventas/Compras
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transacciones - Próximamente')),
        );
        break;
      case 3:
      // Navegar a Entregas
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entregas - Próximamente')),
        );
        break;
      case 4:
      // Navegar a Perfil
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil - Próximamente')),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: _buildDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildResumenSection(),
                    const SizedBox(height: 24),
                    _buildGraficoTendencias(),
                    const SizedBox(height: 24),
                    _buildProductosMasVendidos(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.white,
      ),
      child: Row(
        children: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: AppColors.textPrimary),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          const SizedBox(width: 8),
          // Logo
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'Micro',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                    fontFamily: 'Poppins',
                  ),
                ),
                TextSpan(
                  text: 'Guard',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notificaciones - Próximamente')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.secondary,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Logo en el drawer
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Micro',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  TextSpan(
                    text: 'Guard',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            _buildDrawerItem(Icons.settings, 'Configuración', () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Configuración - Próximamente')),
              );
            }),
            _buildDrawerItem(Icons.group, 'Proveedores', () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Proveedores - Próximamente')),
              );
            }),
            _buildDrawerItem(Icons.people, 'Clientes', () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Clientes - Próximamente')),
              );
            }),
            _buildDrawerItem(Icons.category, 'Categorías', () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Categorías - Próximamente')),
              );
            }),
            const Spacer(),
            _buildDrawerItem(Icons.logout, 'Salir', () async {
              Navigator.pop(context);
              await _handleLogout();
            }, isRed: true),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap, {bool isRed = false}) {
    return ListTile(
      leading: Icon(
        icon,
        color: isRed ? Colors.red : AppColors.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isRed ? Colors.red : AppColors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildResumenSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Bienvenido ${_usuario?.nombres ?? ''}!',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: const Row(
                children: [
                  Text(
                    'Este mes',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, size: 20, color: AppColors.textSecondary),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Resumen',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: const [
            StatCard(
              title: 'Ventas',
              value: 'S/ 86654',
              subtitle: '+84.2 vs anterior',
              backgroundColor: Color(0xFFE3F2FD),
            ),
            StatCard(
              title: 'Compras',
              value: 'S/ 8200',
              subtitle: '4 proveedores',
              backgroundColor: Color(0xFFFFF3E0),
            ),
            StatCard(
              title: 'Ganancia',
              value: 'S/ 2585',
              subtitle: 'Margen %30',
              backgroundColor: Color(0xFFE8F5E9),
            ),
            StatCard(
              title: 'Productos',
              value: '1524',
              subtitle: '12 Categorías',
              backgroundColor: Color(0xFFF3E5F5),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGraficoTendencias() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tendencias de ventas y compras',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 450,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.shade200,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 450,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        );
                      },
                      reservedSize: 40,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['24', '25', '26', '27', '28', '29', '30'];
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          return Text(
                            days[value.toInt()],
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  // Línea de Ventas (azul)
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 900),
                      FlSpot(1, 1350),
                      FlSpot(2, 980),
                      FlSpot(3, 1800),
                      FlSpot(4, 450),
                      FlSpot(5, 1800),
                      FlSpot(6, 1350),
                    ],
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.blue,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(show: false),
                  ),
                  // Línea de Compras (verde)
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 450),
                      FlSpot(1, 500),
                      FlSpot(2, 470),
                      FlSpot(3, 450),
                      FlSpot(4, 460),
                      FlSpot(5, 450),
                      FlSpot(6, 480),
                    ],
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.green,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
                minY: 0,
                maxY: 1800,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Ventas', Colors.blue),
              const SizedBox(width: 20),
              _buildLegendItem('Compras', Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildProductosMasVendidos() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Productos Mas vendidos',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _productosMasVendidos.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final producto = _productosMasVendidos[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: AppColors.background,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                title: Text(
                  producto.nombre,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  'S/${producto.precio.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                trailing: Text(
                  '${producto.unidades} uds',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavBarTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.secondary,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.white.withOpacity(0.6),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '',
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.logout();
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
    }
  }
}