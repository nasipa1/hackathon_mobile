import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ComplaintFormApp extends StatelessWidget {
  const ComplaintFormApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ComplaintFormPage();
  }
}

class ComplaintFormPage extends StatefulWidget {
  const ComplaintFormPage({Key? key}) : super(key: key);

  @override
  _ComplaintFormPageState createState() => _ComplaintFormPageState();
}

class _ComplaintFormPageState extends State<ComplaintFormPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final Map<String, List<String>> regionsCities = {
    "Бишкек": ["Бишкек"],
    "Ош": ["Ош"],
    "Чуйская область": [
      "Токмок", "Кант", "Кара-Балта", "Шопоков", "Беловодское",
      "Сокулук", "Жайыл", "Кемин", "Панфилов", "Московский"
    ],
    "Ошская область": [
      "Узген", "Кара-Суу", "Ноокат", "Кара-Кульджа", "Араван",
      "Чон-Алай", "Алай", "Кызыл-Кия"
    ],
    "Джалал-Абадская область": [
      "Джалал-Абад", "Кербен", "Майлуу-Суу", "Таш-Кумыр",
      "Кок-Жангак", "Казарман", "Чаткал", "Токтогул"
    ],
    "Баткенская область": [
      "Баткен", "Сулюкта", "Кызыл-Кия", "Кадамжай",
      "Лейлек", "Кадамжай"
    ],
    "Нарынская область": [
      "Нарын", "Ат-Башы", "Жумгал", "Кочкор", "Ак-Талаа"
    ],
    "Иссык-Кульская область": [
      "Каракол", "Балыкчы", "Чолпон-Ата", "Кызыл-Суу",
      "Тюп", "Ак-Суу", "Жети-Огуз", "Тон"
    ],
    "Таласская область": [
      "Талас", "Кара-Буура", "Бакай-Ата", "Манас", "Кызыл-Адыр"
    ]
  };
  final List<String> reportTypes = ['Жалоба', 'Рекомендации'];
  final Map<String, dynamic> formData = {
    'report_text': '',
    'recommendations': '',
    'report_type': 'Жалоба',
    'region': '',
    'city': '',
    'address': '',
    'full_name': '',
    'phone': '',
    'email': '',
    'importance': 'medium',
    'language': 'ru'
  };
  bool isSubmitting = false;
  bool showSuccess = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleInputChange(String key, String value) {
    setState(() {
      formData[key] = value;
      if (key == 'region') {
        formData['city'] = '';
      }
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isSubmitting = true);

    try {
      final complaintData = {
        ...formData,
        'contact_info': [
          formData['full_name'],
          formData['phone'],
          formData['email']
        ].where((e) => e.isNotEmpty).join(', '),
        'created_at': DateTime.now().toString(),
        'status': 'pending',
        'submission_source': 'website',
        'location_source': 'manual_input',
        'latitude': null,
        'longitude': null,
        'service': 'Общее обращение',
        'agency': 'Не указано',
      };

      print('Submitting complaint: $complaintData');
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      setState(() {
        showSuccess = true;
        _controller.forward(from: 0);
        formData.updateAll((key, value) => key == 'report_type' ? 'Жалоба' : key == 'importance' ? 'medium' : key == 'language' ? 'ru' : '');
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при отправке: $e')),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Placeholder for ParticlesBackground
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue.shade100, Colors.purple.shade100],
              ),
            ),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: showSuccess ? _buildSuccessScreen() : _buildForm(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessScreen() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 60,
              offset: const Offset(0, 20),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              size: 64,
              color: const Color(0xFF10B981),
            ),
            const SizedBox(height: 16),
            Text(
              'Обращение отправлено!',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: const Color(0xFF065F46),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Ваше обращение успешно зарегистрировано и передано в соответствующие органы.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Номер вашего обращения: #${DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase()}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF667EEA),
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => setState(() {
                      showSuccess = false;
                      _controller.forward(from: 0);
                    }),
                    icon: const Icon(Icons.assignment),
                    label: const Text('Подать еще одно обращение'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/landing'),
                    icon: const Icon(Icons.home),
                    label: const Text('Вернуться на главную'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          Form(
            key: _formKey,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 60,
                    offset: const Offset(0, 20),
                  ),
                ],
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormSection(
                    title: 'Тип обращения',
                    icon: Icons.assignment,
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Тип обращения *',
                        ),
                        value: formData['report_type'],
                        items: reportTypes.map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            )).toList(),
                        onChanged: (value) => _handleInputChange('report_type', value!),
                        validator: (value) => value == null ? 'Обязательное поле' : null,
                      ),
                    ],
                  ),
                  if (formData['report_type'] != 'Рекомендации')
                    _buildFormSection(
                      title: 'Описание проблемы',
                      icon: Icons.feedback,
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Опишите вашу проблему или предложение *',
                            hintText: 'Детально опишите вашу проблему, предложение или жалобу...',
                          ),
                          maxLines: 6,
                          onChanged: (value) => _handleInputChange('report_text', value),
                          validator: (value) => value!.isEmpty ? 'Обязательное поле' : null,
                        ),
                      ],
                    ),
                  _buildFormSection(
                    title: formData['report_type'] == 'Рекомендации' ? 'Рекомендации' : 'Рекомендации по решению',
                    icon: Icons.feedback,
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: formData['report_type'] == 'Рекомендации'
                              ? 'Опишите ваши рекомендации *'
                              : 'Предложите решение проблемы (необязательно)',
                          hintText: formData['report_type'] == 'Рекомендации'
                              ? 'Детально опишите ваши рекомендации...'
                              : 'Если у вас есть идеи о том, как можно решить эту проблему, опишите их здесь...',
                        ),
                        maxLines: formData['report_type'] == 'Рекомендации' ? 6 : 4,
                        onChanged: (value) => _handleInputChange('recommendations', value),
                        validator: (value) => formData['report_type'] == 'Рекомендации' && value!.isEmpty ? 'Обязательное поле' : null,
                      ),
                    ],
                  ),
                  _buildFormSection(
                    title: 'Местоположение',
                    icon: Icons.location_on,
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Регион *',
                        ),
                        value: formData['region'].isEmpty ? null : formData['region'],
                        items: regionsCities.keys.map((region) => DropdownMenuItem(
                              value: region,
                              child: Text(
                                region,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )).toList(),
                        onChanged: (value) => _handleInputChange('region', value!),
                        validator: (value) => value == null ? 'Обязательное поле' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Город/населенный пункт *',
                          hintText: formData['region'].isEmpty ? 'Сначала выберите регион' : 'Выберите город',
                        ),
                        value: formData['city'].isEmpty ? null : formData['city'],
                        items: formData['region'].isNotEmpty
                            ? regionsCities[formData['region']]!.map((city) => DropdownMenuItem(
                                  value: city,
                                  child: Text(
                                    city,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )).toList()
                            : [],
                        onChanged: formData['region'].isNotEmpty
                            ? (value) => _handleInputChange('city', value!)
                            : null,
                        validator: (value) => value == null ? 'Обязательное поле' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Адрес (необязательно)',
                          hintText: 'Укажите конкретный адрес, если необходимо',
                        ),
                        onChanged: (value) => _handleInputChange('address', value),
                      ),
                    ],
                  ),
                  _buildFormSection(
                    title: 'Контактная информация',
                    icon: Icons.contact_mail,
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Email *',
                          hintText: 'example@email.com',
                          prefixIcon: Icon(Icons.email, size: 20),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) => _handleInputChange('email', value),
                        validator: (value) {
                          if (value!.isEmpty) return 'Обязательное поле';
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Неверный формат email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'ФИО (необязательно)',
                          hintText: 'Укажите ваше полное имя',
                          prefixIcon: Icon(Icons.person, size: 20),
                        ),
                        onChanged: (value) => _handleInputChange('full_name', value),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Телефон (необязательно)',
                          hintText: '+996 XXX XXX XXX',
                          prefixIcon: Icon(Icons.phone, size: 20),
                        ),
                        keyboardType: TextInputType.phone,
                        onChanged: (value) => _handleInputChange('phone', value),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Email обязателен для получения уведомлений о статусе вашего обращения',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isSubmitting ? null : _handleSubmit,
                          child: Text(isSubmitting ? 'Отправка...' : 'Отправить обращение'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: () => Navigator.pushReplacementNamed(context, '/landing'),
                          icon: const Icon(Icons.home),
                          label: const Text('Отмена'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF667EEA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'PublicPulse',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 18,
                      foreground: Paint()
                        ..shader = const LinearGradient(
                          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                        ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Подача обращения',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: 24,
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Заполните форму ниже, чтобы подать обращение или жалобу',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF667EEA).withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 24, color: const Color(0xFF667EEA)),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}