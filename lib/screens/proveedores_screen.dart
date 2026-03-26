import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/proveedor.dart';
import '../services/proveedor_service.dart';
import '../utils/app_theme.dart';

class ProveedoresScreen extends StatefulWidget {
  const ProveedoresScreen({super.key});

  @override
  State<ProveedoresScreen> createState() => _ProveedoresScreenState();
}

class _ProveedoresScreenState extends State<ProveedoresScreen>
    with SingleTickerProviderStateMixin {
  final _proveedorService = ProveedorService();
  final _searchController = TextEditingController();

  List<Proveedor> _proveedores = [];
  bool _isLoading = true;
  late TabController _tabController;

  // Filtros
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _cargarProveedores();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ── Carga ─────────────────────────────────────────────────────────────────

  Future<void> _cargarProveedores() async {
    setState(() => _isLoading = true);
    final result = await _proveedorService.listarProveedores();
    if (!mounted) return;

    if (result['success']) {
      setState(() {
        _proveedores = result['data'] as List<Proveedor>;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      _showSnackBar(result['message'] ?? 'Error al cargar', isError: true);
    }
  }

  // ── Filtrado local ────────────────────────────────────────────────────────

  List<Proveedor> _filtrar(bool activos) {
    return _proveedores.where((p) {
      final matchEstado = p.estado == activos;
      if (_busqueda.isEmpty) return matchEstado;
      final q = _busqueda.toLowerCase();
      return matchEstado &&
          (p.razonSocial.toLowerCase().contains(q) ||
              p.documento.toLowerCase().contains(q) ||
              p.telefono.toLowerCase().contains(q));
    }).toList();
  }

  List<Proveedor> get _activos => _proveedores.where((p) => p.estado).toList();
  List<Proveedor> get _inactivos =>
      _proveedores.where((p) => !p.estado).toList();

  // ── Helpers UI ────────────────────────────────────────────────────────────

  void _showSnackBar(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── Modal REGISTRAR ───────────────────────────────────────────────────────

  void _mostrarModalRegistrar() {
    final formKey = GlobalKey<FormState>();
    String tipoSeleccionado = 'Natural';
    final docCtrl = TextEditingController();
    final razonCtrl = TextEditingController();
    final telCtrl = TextEditingController();
    bool loading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => _buildModal(
          title: 'Nuevo proveedor',
          subtitle: 'Completa los datos para registrar un proveedor',
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Selector tipo proveedor
                const Text(
                  'Tipo de proveedor *',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: ['Natural', 'Empresa'].map((tipo) {
                    final selected = tipoSeleccionado == tipo;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setModalState(() => tipoSeleccionado = tipo),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.only(
                              right: tipo == 'Natural' ? 8 : 0),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primary
                                : AppColors.background,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.inputBorder.withOpacity(0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                tipo == 'Natural'
                                    ? Icons.person_outline
                                    : Icons.business_outlined,
                                size: 18,
                                color: selected
                                    ? AppColors.white
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                tipo,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? AppColors.white
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // Documento
                TextFormField(
                  controller: docCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: tipoSeleccionado == 'Natural' ? 'DNI *' : 'RUC *',
                    hintText: tipoSeleccionado == 'Natural'
                        ? '12345678'
                        : '20123456789',
                    prefixIcon: const Icon(Icons.badge_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'El documento es obligatorio';
                    }
                    if (tipoSeleccionado == 'Natural' && v.length != 8) {
                      return 'El DNI debe tener 8 dígitos';
                    }
                    if (tipoSeleccionado == 'Empresa' && v.length != 11) {
                      return 'El RUC debe tener 11 dígitos';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Razón Social / Nombre
                TextFormField(
                  controller: razonCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: tipoSeleccionado == 'Natural'
                        ? 'Nombre completo *'
                        : 'Razón social *',
                    hintText: tipoSeleccionado == 'Natural'
                        ? 'Juan Pérez García'
                        : 'Distribuidora SAC',
                    prefixIcon: Icon(tipoSeleccionado == 'Natural'
                        ? Icons.person_outline
                        : Icons.business_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Teléfono
                TextFormField(
                  controller: telCtrl,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    hintText: '987654321',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (v) {
                    if (v != null && v.isNotEmpty && v.length != 9) {
                      return 'El teléfono debe tener 9 dígitos';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 28),

                _buildBotonesModal(
                  ctx: ctx,
                  loading: loading,
                  labelConfirmar: 'Registrar',
                  onConfirmar: () async {
                    if (!formKey.currentState!.validate()) return;
                    setModalState(() => loading = true);

                    final result = await _proveedorService.registrarProveedor(
                      tipoProveedor: tipoSeleccionado,
                      documento: docCtrl.text.trim(),
                      razonSocial: razonCtrl.text.trim(),
                      telefono: telCtrl.text.trim(),
                    );

                    setModalState(() => loading = false);
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);

                    if (result['success']) {
                      _showSnackBar(
                          result['message'] ?? 'Proveedor registrado');
                      _cargarProveedores();
                    } else {
                      _showSnackBar(result['message'] ?? 'Error',
                          isError: true);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Modal EDITAR ──────────────────────────────────────────────────────────

  void _mostrarModalEditar(Proveedor proveedor) {
    final formKey = GlobalKey<FormState>();
    final razonCtrl = TextEditingController(text: proveedor.razonSocial);
    final telCtrl = TextEditingController(text: proveedor.telefono);
    bool loading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => _buildModal(
          title: 'Editar proveedor',
          subtitle: 'Solo puedes modificar la razón social y el teléfono',
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info no editable (documento y tipo)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.inputBorder.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        proveedor.tipoProveedor == 'Natural'
                            ? Icons.person_outline
                            : Icons.business_outlined,
                        color: AppColors.secondary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            proveedor.tipoProveedor,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            proveedor.documento,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'No editable',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: razonCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: proveedor.tipoProveedor == 'Natural'
                        ? 'Nombre completo *'
                        : 'Razón social *',
                    prefixIcon: const Icon(Icons.drive_file_rename_outline),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: telCtrl,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    hintText: '987654321',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (v) {
                    if (v != null && v.isNotEmpty && v.length != 9) {
                      return 'El teléfono debe tener 9 dígitos';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 28),

                _buildBotonesModal(
                  ctx: ctx,
                  loading: loading,
                  labelConfirmar: 'Guardar',
                  onConfirmar: () async {
                    if (!formKey.currentState!.validate()) return;
                    setModalState(() => loading = true);

                    final result = await _proveedorService.editarProveedor(
                      id: proveedor.id,
                      razonSocial: razonCtrl.text.trim(),
                      telefono: telCtrl.text.trim(),
                    );

                    setModalState(() => loading = false);
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);

                    if (result['success']) {
                      _showSnackBar(
                          result['message'] ?? 'Proveedor actualizado');
                      _cargarProveedores();
                    } else {
                      _showSnackBar(result['message'] ?? 'Error',
                          isError: true);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Cambiar estado ────────────────────────────────────────────────────────

  Future<void> _confirmarCambioEstado(Proveedor p) async {
    final accion = p.estado ? 'deshabilitar' : 'habilitar';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
            '¿${accion[0].toUpperCase()}${accion.substring(1)} proveedor?'),
        content: Text(
            '¿Estás seguro de que deseas $accion a "${p.razonSocial}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: p.estado ? AppColors.error : AppColors.success,
            ),
            child: Text(
              p.estado ? 'Deshabilitar' : 'Habilitar',
              style: const TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final result = await _proveedorService.cambiarEstado(
      id: p.id,
      nuevoEstado: !p.estado,
    );

    if (result['success']) {
      _showSnackBar(result['message'] ?? 'Estado actualizado');
      _cargarProveedores();
    } else {
      _showSnackBar(result['message'] ?? 'Error', isError: true);
    }
  }

  // ── Widgets reutilizables ─────────────────────────────────────────────────

  Widget _buildModal({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildBotonesModal({
    required BuildContext ctx,
    required bool loading,
    required String labelConfirmar,
    required VoidCallback onConfirmar,
  }) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.secondary, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                  color: AppColors.secondary, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: loading ? null : onConfirmar,
            child: loading
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor:
                AlwaysStoppedAnimation<Color>(AppColors.white),
              ),
            )
                : Text(labelConfirmar),
          ),
        ),
      ],
    );
  }

  // ── BUILD PRINCIPAL ───────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Proveedores'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            fontFamily: 'Poppins',
          ),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Activos'),
                  const SizedBox(width: 6),
                  _buildBadge(_activos.length, AppColors.success),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Inactivos'),
                  const SizedBox(width: 6),
                  _buildBadge(_inactivos.length, AppColors.error),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Buscador
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _busqueda = v),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, documento o teléfono...',
                prefixIcon: const Icon(Icons.search,
                    color: AppColors.textSecondary),
                suffixIcon: _busqueda.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear,
                      color: AppColors.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _busqueda = '');
                  },
                )
                    : null,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Lista con tabs
          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(
                valueColor:
                AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
                : TabBarView(
              controller: _tabController,
              children: [
                _buildLista(activos: true),
                _buildLista(activos: false),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarModalRegistrar,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add_outlined, color: AppColors.white),
        label: const Text(
          'Nuevo proveedor',
          style: TextStyle(
              color: AppColors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildBadge(int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildLista({required bool activos}) {
    final lista = _filtrar(activos);

    if (lista.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              activos
                  ? Icons.group_outlined
                  : Icons.person_off_outlined,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              _busqueda.isNotEmpty
                  ? 'Sin resultados para "$_busqueda"'
                  : activos
                  ? 'No hay proveedores activos'
                  : 'No hay proveedores inactivos',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarProveedores,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
        itemCount: lista.length,
        itemBuilder: (_, i) => _buildProveedorCard(lista[i]),
      ),
    );
  }

  Widget _buildProveedorCard(Proveedor p) {
    final esEmpresa = p.tipoProveedor == 'Empresa';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: p.estado
                    ? (esEmpresa
                    ? AppColors.secondary.withOpacity(0.12)
                    : AppColors.primary.withOpacity(0.12))
                    : Colors.grey.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                esEmpresa
                    ? Icons.business_rounded
                    : Icons.person_rounded,
                color: p.estado
                    ? (esEmpresa ? AppColors.secondary : AppColors.primary)
                    : Colors.grey,
                size: 24,
              ),
            ),

            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre + chip tipo
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          p.razonSocial,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: p.estado
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      _buildChip(
                        label: p.tipoProveedor,
                        color: esEmpresa
                            ? AppColors.secondary
                            : AppColors.primary,
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Documento
                  Row(
                    children: [
                      const Icon(Icons.badge_outlined,
                          size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        p.documento,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  // Teléfono
                  if (p.telefono.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined,
                            size: 13, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          p.telefono,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Acciones
            Column(
              children: [
                if (p.estado)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        color: AppColors.secondary, size: 20),
                    tooltip: 'Editar',
                    onPressed: () => _mostrarModalEditar(p),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _confirmarCambioEstado(p),
                  child: Icon(
                    p.estado
                        ? Icons.toggle_on_rounded
                        : Icons.toggle_off_rounded,
                    color: p.estado ? AppColors.success : Colors.grey,
                    size: 32,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}