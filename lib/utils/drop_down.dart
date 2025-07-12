import 'package:flutter/material.dart';
import 'package:vinyl_collection_app_gruppo_16/utils/constants.dart';
import 'package:provider/provider.dart';





class ChangeNotifierDropDown extends ChangeNotifier {
  String _year = DateTime.now().year.toString();

  String get year => _year;

  void setYear(String newYear) {
    if ( newYear != _year) {
      _year = newYear;
      notifyListeners();
    }
  }
}

class DropDownMenu extends StatefulWidget {
  const DropDownMenu({super.key});

  @override
  State<DropDownMenu> createState() => _DropDownState();
}
  
class _DropDownState extends State<DropDownMenu> {
  String _selectedYear = DateTime.now().year.toString();

  void setAnno(String anno) {
    if (_selectedYear != anno) {
      setState(() {
        _selectedYear = anno;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: _selectedYear,
      isExpanded: false,
      icon: const Icon(Icons.arrow_drop_down),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(color: Colors.black),
      underline: Container(
        height: 2,
        color: AppConstants.primaryColor,
      ),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setAnno(newValue);
        }
        Provider.of<ChangeNotifierDropDown>(context, listen: false).setYear(_selectedYear);
      },
      items: List.generate(10, (i) {
        return DropdownMenuItem(
          value: '${DateTime.now().year - i}',
          child: Text(
            (DateTime.now().year - i).toString(),
            style: const TextStyle(fontSize: 16),
          ),
        );
      }),
    );
  }
}