import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';


//core bcz more than on feature might use getSt serv: note app, user profile, to do list.etc
//extending GetxService to tell flutter to KEEP IT PERMENANT (not temporary like a controller)
class StorageService extends GetxService {


//init storage
  final _box = GetStorage();


//dynamic bcz its core, any feature can use it accoriding to its  data requirements
//we dont know what kind of data will be coming throu storage , its unsure.
  dynamic readData(String key) {
    return _box.read(key);
  }

  Future<void> writeData(String key, dynamic value) {
    return _box.write(key, value);
  }
}
