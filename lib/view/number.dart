import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:login_page/view/OTP.dart';

/// مدل اطلاعات کشور
class CountryInfo {
  final String name;
  final String code;
  final String dialCode;
  final String flag;
  final int minLength;
  final int maxLength;

  const CountryInfo({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flag,
    required this.minLength,
    required this.maxLength,
  });
}

/// لیست کشورهای محبوب
const List<CountryInfo> countryList = [
  CountryInfo(
    name: 'Iran',
    code: 'IR',
    dialCode: '+98',
    flag: '🇮🇷',
    minLength: 9,
    maxLength: 10,
  ),
  CountryInfo(
    name: 'United States',
    code: 'US',
    dialCode: '+1',
    flag: '🇺🇸',
    minLength: 10,
    maxLength: 10,
  ),
  CountryInfo(
    name: 'United Kingdom',
    code: 'GB',
    dialCode: '+44',
    flag: '🇬🇧',
    minLength: 10,
    maxLength: 10,
  ),
  CountryInfo(
    name: 'Germany',
    code: 'DE',
    dialCode: '+49',
    flag: '🇩🇪',
    minLength: 10,
    maxLength: 11,
  ),
  CountryInfo(
    name: 'Canada',
    code: 'CA',
    dialCode: '+1',
    flag: '🇨🇦',
    minLength: 10,
    maxLength: 10,
  ),
  CountryInfo(
    name: 'United Arab Emirates',
    code: 'AE',
    dialCode: '+971',
    flag: '🇦🇪',
    minLength: 9,
    maxLength: 9,
  ),
  CountryInfo(
    name: 'Turkey',
    code: 'TR',
    dialCode: '+90',
    flag: '🇹🇷',
    minLength: 10,
    maxLength: 10,
  ),
  CountryInfo(
    name: 'France',
    code: 'FR',
    dialCode: '+33',
    flag: '🇫🇷',
    minLength: 9,
    maxLength: 9,
  ),
  CountryInfo(
    name: 'Italy',
    code: 'IT',
    dialCode: '+39',
    flag: '🇮🇹',
    minLength: 10,
    maxLength: 10,
  ),
  CountryInfo(
    name: 'Russia',
    code: 'RU',
    dialCode: '+7',
    flag: '🇷🇺',
    minLength: 10,
    maxLength: 10,
  ),
];

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const Color darkBg = Color(0xFF090909);

  CountryInfo _selectedCountry = countryList[0];

  final TextEditingController _phoneController =
      TextEditingController();

  final FocusNode _phoneFocusNode = FocusNode();

  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();

    _phoneController.addListener(_validatePhoneNumber);

    // فوکوس نرم‌تر هنگام ورود به صفحه
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _phoneFocusNode.requestFocus();
      }
    });
  }

  void _validatePhoneNumber() {
    final text = _phoneController.text.trim();

    final isValid =
        text.length >= _selectedCountry.minLength &&
        text.length <= _selectedCountry.maxLength;

    if (isValid != _isButtonEnabled) {
      setState(() {
        _isButtonEnabled = isValid;
      });
    }
  }

  void _changeCountry(CountryInfo country) {
    setState(() {
      _selectedCountry = country;

      // بعد از تغییر کشور، وضعیت دکمه دوباره بررسی شود
      _isButtonEnabled = false;
    });

    _validatePhoneNumber();
  }

  void _continue() {
    if (!_isButtonEnabled) return;

    FocusScope.of(context).unfocus();

    final phone =
        _phoneController.text.trim();

    final fullNumber =
        '${_selectedCountry.dialCode}$phone';

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OtpVerification(
          phoneNumber: fullNumber,
        ),
      ),
    );
  }

  /// انتخاب کشور
  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161616),
      barrierColor: Colors.black.withOpacity(0.7),
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (bottomSheetContext) {
        final searchController = TextEditingController();
        List<CountryInfo> filteredCountries = countryList;

        return StatefulBuilder(
          builder: (context, setModalState) {
            void searchCountry(String query) {
              final normalizedQuery = query.trim().toLowerCase();

              setModalState(() {
                if (normalizedQuery.isEmpty) {
                  filteredCountries = countryList;
                } else {
                  filteredCountries = countryList.where((country) {
                    return country.name
                            .toLowerCase()
                            .contains(normalizedQuery) ||
                        country.dialCode
                            .contains(normalizedQuery) ||
                        country.code
                            .toLowerCase()
                            .contains(normalizedQuery);
                  }).toList();
                }
              });
            }

            return SizedBox(
              height:
                  MediaQuery.of(context).size.height * 0.75,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    // دستگیره
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Select Country',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // جستجو
                    TextField(
                      controller: searchController,
                      onChanged: searchCountry,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      textInputAction: TextInputAction.search,
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        hintText: 'Search country',
                        hintStyle: const TextStyle(
                          color: Colors.white38,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: Colors.white54,
                        ),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  searchController.clear();
                                  searchCountry('');
                                },
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.white54,
                                ),
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.06),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Colors.white24,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    Expanded(
                      child: filteredCountries.isEmpty
                          ? const Center(
                              child: Text(
                                'No country found',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 15,
                                ),
                              ),
                            )
                          : ListView.separated(
                              keyboardDismissBehavior:
                                  ScrollViewKeyboardDismissBehavior
                                      .onDrag,
                              itemCount:
                                  filteredCountries.length,
                              separatorBuilder:
                                  (context, index) {
                                return Divider(
                                  color: Colors.white
                                      .withOpacity(0.06),
                                  height: 1,
                                );
                              },
                              itemBuilder:
                                  (context, index) {
                                final country =
                                    filteredCountries[index];

                                final isSelected =
                                    country.code ==
                                        _selectedCountry.code;

                                return Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius:
                                        BorderRadius.circular(
                                      16,
                                    ),
                                    onTap: () {
                                      _changeCountry(country);
                                      Navigator.pop(
                                        bottomSheetContext,
                                      );
                                    },
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 42,
                                            child: Text(
                                              country.flag,
                                              textAlign:
                                                  TextAlign.center,
                                              style:
                                                  const TextStyle(
                                                fontSize: 28,
                                              ),
                                            ),
                                          ),

                                          const SizedBox(
                                            width: 12,
                                          ),

                                          Expanded(
                                            child: Text(
                                              country.name,
                                              style: TextStyle(
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.white70,
                                                fontSize: 16,
                                                fontWeight:
                                                    isSelected
                                                        ? FontWeight.bold
                                                        : FontWeight.w500,
                                              ),
                                            ),
                                          ),

                                          const SizedBox(
                                            width: 12,
                                          ),

                                          Text(
                                            country.dialCode,
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.white38,
                                              fontSize: 16,
                                              fontWeight:
                                                  FontWeight.w600,
                                            ),
                                          ),

                                          const SizedBox(
                                            width: 8,
                                          ),

                                          AnimatedSwitcher(
                                            duration:
                                                const Duration(
                                              milliseconds: 180,
                                            ),
                                            child: isSelected
                                                ? const Icon(
                                                    Icons
                                                        .check_rounded,
                                                    key: ValueKey(
                                                      'selected',
                                                    ),
                                                    color:
                                                        Colors.white,
                                                    size: 20,
                                                  )
                                                : const SizedBox(
                                                    key: ValueKey(
                                                      'empty',
                                                    ),
                                                    width: 20,
                                                    height: 20,
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,

      // جلوگیری از بهم‌ریختگی صفحه هنگام باز شدن کیبورد
      resizeToAvoidBottomInset: true,

      appBar: AppBar(
        backgroundColor: darkBg,
        elevation: 0,

        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // عنوان
              const Text(
                'Enter your phone\nnumber',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 40),

              // انتخاب کشور
              Semantics(
                button: true,
                label:
                    'Selected country ${_selectedCountry.name}, ${_selectedCountry.dialCode}',
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: _showCountryPicker,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 2,
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedCountry.flag,
                            style: const TextStyle(
                              fontSize: 32,
                            ),
                          ),

                          const SizedBox(width: 10),

                          Text(
                            _selectedCountry.dialCode,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),

                          const SizedBox(width: 6),

                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.white54,
                            size: 28,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // شماره تلفن
              TextField(
                controller: _phoneController,
                focusNode: _phoneFocusNode,

                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: false,
                  signed: false,
                ),

                textInputAction: TextInputAction.done,

                onSubmitted: (_) {
                  if (_isButtonEnabled) {
                    _continue();
                  }
                },

                autofocus: false,

                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.0,
                ),

                cursorColor: Colors.white,
                cursorWidth: 2,
                cursorRadius: const Radius.circular(2),

                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(
                    _selectedCountry.maxLength,
                  ),
                ],

                decoration: InputDecoration(
                  hintText: 'Phone number',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.18),
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0,
                  ),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),

              const Spacer(),

              // Continue
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      _isButtonEnabled ? _continue : null,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    disabledBackgroundColor:
                        Colors.white.withOpacity(0.12),
                    foregroundColor: darkBg,
                    disabledForegroundColor: Colors.white38,

                    elevation: _isButtonEnabled ? 6 : 0,

                    shadowColor:
                        Colors.white.withOpacity(0.3),

                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(28),
                    ),
                  ),

                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}