import 'package:flutter/material.dart';
import '../models/categoria.dart';
import '../services/categoria_service.dart';
import '../utils/app_theme.dart';

class CategoriasScreen extends StatefulWidget {
  const CategoriasScreen({super.key});

  @override
  State<CategoriasScreen> createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen>
    with SingleTickerProviderStateMixin {
  final _categoriaService = CategoriaService();
  List<Categoria> _categorias = [];
  List<Categoria> _categoriasFiltradas = [];
  bool _isLoading = true;
  String _busqueda = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _cargarCategorias();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargarCategorias() async {
    setState(() => _isLoading = true);
    final result = await _categoriaService.listarCategorias();
    if (result['success']) {
      setState(() {
        _categorias = result['data'] as List<Categoria>;
        _filtrar();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        _showSnackBar(result['message'] ?? 'Error al cargar', isError: true);
      }
    }
  }

  void _filtrar() {
    final q = _busqueda.toLowerCase();
    _categoriasFiltradas = _categorias.where((c) {
      final matchNombre = c.nombre.toLowerCase().contains(q);
      final matchDesc = c.descripcion.toLowerCase().contains(q);
      final isActivo = _tabController.index == 0 ? c.estado : !c.estado;
      return (matchNombre || matchDesc) && isActivo;
    }).toList();
  }

  List<Categoria> get _activas => _categorias.where((c) => c.estado).toList();
  List<Categoria> get _inactivas => _categorias.where((c) => !c.estado).toList();

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

  // ─── MODAL CREAR / EDITAR ─────────────────────────────────────────────────

  void _mostrarModal({Categoria? categoria}) {
    final isEdicion = categoria != null;
    final nombreCtrl = TextEditingController(text: categoria?.nombre ?? '');
    final descCtrl = TextEditingController(text: categoria?.descripcion ?? '');
    final formKey = GlobalKey<FormState>();
    bool loading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle bar
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
                        isEdicion ? 'Editar categoría' : 'Nueva categoría',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isEdicion
                            ? 'Modifica los datos de la categoría'
                            : 'Completa los campos para crear una categoría',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: nombreCtrl,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Nombre *',
                          hintText: 'Ej: Abarrotes',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'El nombre es obligatorio';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: descCtrl,
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Descripción',
                          hintText: 'Describe brevemente la categoría...',
                          prefixIcon: Icon(Icons.notes_outlined),
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: AppColors.secondary, width: 1.5),
                                padding:
                                const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Cancelar',
                                style: TextStyle(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: loading
                                  ? null
                                  : () async {
                                if (!formKey.currentState!.validate()) {
                                  return;
                                }
                                setModalState(() => loading = true);

                                Map<String, dynamic> result;
                                if (isEdicion) {
                                  result = await _categoriaService
                                      .actualizarCategoria(
                                    id: categoria.id,
                                    nombre: nombreCtrl.text.trim(),
                                    descripcion: descCtrl.text.trim(),
                                  );
                                } else {
                                  result = await _categoriaService
                                      .crearCategoria(
                                    nombre: nombreCtrl.text.trim(),
                                    descripcion: descCtrl.text.trim(),
                                  );
                                }

                                setModalState(() => loading = false);
                                if (!ctx.mounted) return;
                                Navigator.pop(ctx);

                                if (result['success']) {
                                  _showSnackBar(result['message'] ??
                                      'Operación exitosa');
                                  _cargarCategorias();
                                } else {
                                  _showSnackBar(
                                      result['message'] ?? 'Error',
                                      isError: true);
                                }
                              },
                              child: loading
                                  ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                  AlwaysStoppedAnimation<Color>(
                                      AppColors.white),
                                ),
                              )
                                  : Text(isEdicion ? 'Guardar' : 'Crear'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ─── CONFIRMAR CAMBIO DE ESTADO ───────────────────────────────────────────

  Future<void> _confirmarCambioEstado(Categoria cat) async {
    final accion = cat.estado ? 'deshabilitar' : 'habilitar';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('¿${accion[0].toUpperCase()}${accion.substring(1)} categoría?'),
        content: Text(
          '¿Estás seguro de que deseas $accion la categoría "${cat.nombre}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor:
              cat.estado ? AppColors.error : AppColors.success,
            ),
            child: Text(
              cat.estado ? 'Deshabilitar' : 'Habilitar',
              style: const TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final result = cat.estado
        ? await _categoriaService.deshabilitarCategoria(cat.id)
        : await _categoriaService.habilitarCategoria(cat.id);

    if (result['success']) {
      _showSnackBar(result['message'] ?? 'Estado actualizado');
      _cargarCategorias();
    } else {
      _showSnackBar(result['message'] ?? 'Error', isError: true);
    }
  }

  // ─── BUILD ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Categorías'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          onTap: (_) {
            setState(() => _filtrar());
          },
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
                  const Text('Activas'),
                  const SizedBox(width: 6),
                  _buildTabBadge(_activas.length, AppColors.success),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Inactivas'),
                  const SizedBox(width: 6),
                  _buildTabBadge(_inactivas.length, AppColors.error),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() {
                _busqueda = v;
                _filtrar();
              }),
              decoration: InputDecoration(
                hintText: 'Buscar categoría...',
                prefixIcon:
                const Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: _busqueda.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear,
                      color: AppColors.textSecondary),
                  onPressed: () => setState(() {
                    _busqueda = '';
                    _filtrar();
                  }),
                )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Lista
          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primary),
              ),
            )
                : TabBarView(
              controller: _tabController,
              children: [
                _buildLista(activas: true),
                _buildLista(activas: false),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarModal(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: AppColors.white),
        label: const Text(
          'Nueva categoría',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTabBadge(int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildLista({required bool activas}) {
    final lista = _categoriasFiltradas.where((c) => c.estado == activas).toList();

    if (lista.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              activas ? Icons.category_outlined : Icons.block_outlined,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              _busqueda.isNotEmpty
                  ? 'Sin resultados para "$_busqueda"'
                  : activas
                  ? 'No hay categorías activas'
                  : 'No hay categorías inactivas',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarCategorias,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
        itemCount: lista.length,
        itemBuilder: (context, index) => _buildCategoriaCard(lista[index]),
      ),
    );
  }

  Widget _buildCategoriaCard(Categoria cat) {
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
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: cat.estado
                ? AppColors.primary.withOpacity(0.12)
                : Colors.grey.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.category_rounded,
            color: cat.estado ? AppColors.primary : Colors.grey,
            size: 24,
          ),
        ),
        title: Text(
          cat.nombre,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: cat.estado ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        subtitle: cat.descripcion.isNotEmpty
            ? Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            cat.descripcion,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Botón editar (solo si está activa)
            if (cat.estado)
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    color: AppColors.secondary, size: 20),
                tooltip: 'Editar',
                onPressed: () => _mostrarModal(categoria: cat),
              ),
            // Botón habilitar/deshabilitar
            IconButton(
              icon: Icon(
                cat.estado
                    ? Icons.toggle_on_rounded
                    : Icons.toggle_off_rounded,
                color: cat.estado ? AppColors.success : Colors.grey,
                size: 30,
              ),
              tooltip: cat.estado ? 'Deshabilitar' : 'Habilitar',
              onPressed: () => _confirmarCambioEstado(cat),
            ),
          ],
        ),
      ),
    );
  }
}