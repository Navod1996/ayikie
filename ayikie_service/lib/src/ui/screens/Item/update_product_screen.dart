import 'dart:io';

import 'package:ayikie_service/src/api/api_calls.dart';
import 'package:ayikie_service/src/app_colors.dart';
import 'package:ayikie_service/src/models/dropdown.dart';
import 'package:ayikie_service/src/models/product.dart';
import 'package:ayikie_service/src/models/service.dart';
import 'package:ayikie_service/src/ui/screens/drawer_screen/drawer_screen.dart';
import 'package:ayikie_service/src/ui/screens/notification_screen/notification_screen.dart';
import 'package:ayikie_service/src/ui/widget/custom_form_field.dart';
import 'package:ayikie_service/src/ui/widget/image_source_dialog.dart';
import 'package:ayikie_service/src/ui/widget/primary_button.dart';
import 'package:ayikie_service/src/ui/widget/progress_view.dart';
import 'package:ayikie_service/src/utils/alerts.dart';
import 'package:ayikie_service/src/utils/validations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class UpdateProductScreen extends StatefulWidget {
  final Product product;
  UpdateProductScreen({Key? key,required this.product}) : super(key: key);

  @override
  _UpdateProductScreenState createState() => _UpdateProductScreenState();
}

class _UpdateProductScreenState extends State<UpdateProductScreen> {
  bool _isLoading = true;

  File? _servicePhoto;
  bool isUploaded = false;

  List<Dropdown> productCategories = [];
  List<Dropdown> productSubCategories = [];

  late Dropdown selectedProductCategory;
  late Dropdown selectedSubProductCategory;

  TextEditingController _titleController = TextEditingController();
  TextEditingController _shortDescriptionController = TextEditingController();
  TextEditingController _fullDescriptionController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _stockController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getServiceCategory();
    _titleController.text = widget.product.name;
    _shortDescriptionController.text = widget.product.introduction;
    _fullDescriptionController.text = widget.product.description!;
    _locationController.text = widget.product.location;
    _priceController.text = widget.product.price.toString();
    _stockController.text = widget.product.stock.toString();
  }

  void _getServiceCategory() async {
    await ApiCalls.getProductsDropdown().then((response) {
      if (!mounted) {
        return;
      }
      if (response.isSuccess) {
        var data = response.jsonBody;
        productCategories.clear();
        for (var item in data) {
          Dropdown dropdown = Dropdown.fromJson(item);
          productCategories.add(dropdown);
        }
        selectedProductCategory = productCategories[0];
        _getSubServiceCategory(selectedProductCategory.id);
      } else {
        Alerts.showMessage(context, "Something went wrong. Please try again.",
            title: "Oops!");
      }
    });
  }

  void _getSubServiceCategory(int categoryId) async {
    await ApiCalls.getSubProductsDropdown(categoryId: categoryId).then((
        response) {
      if (!mounted) {
        return;
      }
      if (response.isSuccess) {
        var data = response.jsonBody;
        productSubCategories.clear();
        for (var item in data) {
          Dropdown dropdown = Dropdown.fromJson(item);
          productSubCategories.add(dropdown);
        }
        selectedSubProductCategory = productSubCategories[0];
      } else {
        Alerts.showMessage(context, "Something went wrong. Please try again.",
            title: "Oops!");
      }
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColors.black),
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Product',
          style: TextStyle(color: Colors.black),
        ),
        leading: Container(
          width: 24,
          height: 24,
          child: new IconButton(
            icon: new Icon(
              Icons.arrow_back_ios,
              color: AppColors.black,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        actions: [
          Builder(
            builder: (context) => GestureDetector(
              onTap: () => Scaffold.of(context).openEndDrawer(),
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) {
                            return NotificationScreen();
                          }),
                        );
                      },
                      child: Container(
                        width: 26,
                        height: 26,
                        child: new Icon(
                          Icons.notifications_none,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      width: 26,
                      height: 26,
                      child: RotationTransition(
                        turns: AlwaysStoppedAnimation(180 / 360),
                        child: Image.asset(
                          'asserts/icons/menu.png',
                          scale: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      endDrawer: DrawerScreen(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(left: 16, right: 16, top: 20),
            child: _isLoading
                ? Center(
              child: ProgressView(),
            ) : Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Item Image',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: 10,
                ),
                isUploaded ?
                Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.textFieldBackground,
                    ),
                    width: double.infinity,
                    height: 75,
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.center,
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                        Text('Uploaded Successfully'),
                      ],
                    )
                ) :
                GestureDetector(
                  onTap: _updatePicture,
                  child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.textFieldBackground,
                      ),
                      width: double.infinity,
                      height: 75,
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.center,
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_outlined),
                          Text('Photos'),
                        ],
                      )
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Title',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: 10,
                ),
                CustomFormField(
                  controller: _titleController,
                  hintText: 'Enter title here',
                  inputType: TextInputType.text,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Short Description',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: 10,
                ),
                CustomFormField(
                  controller: _shortDescriptionController,
                  hintText: 'Enter short description here',
                  inputType: TextInputType.text,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Full Description',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  height: 100,
                  child: TextField(
                    maxLines: 9,
                    controller: _fullDescriptionController,
                    decoration: InputDecoration(
                        hintText: "Enter your description here",
                        fillColor: AppColors.transparent,
                        filled: true,
                        hintStyle:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                            color: AppColors.greyLightColor,
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                              color: AppColors.greyLightColor, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.only(
                          left: 15,
                          top: 30,
                        )),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Category',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: 10,
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.all(Radius.circular(8)),
                    border: Border.all(
                        width: 1, //
                        color: AppColors
                            .greyLightColor //            <--- border width here
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: DropdownButton<Dropdown>(
                      value: selectedProductCategory,
                      isExpanded: true,
                      iconEnabledColor: AppColors.primaryButtonColor,
                      items: productCategories.map((Dropdown value) {
                        return DropdownMenuItem<Dropdown>(
                          value: value,
                          child: Text(value.name),
                        );
                      }).toList(),
                      underline: SizedBox(
                        width: 120,
                      ),
                      icon: const Icon(Icons.keyboard_arrow_down),
                      onChanged: (Dropdown? newValue) {
                        setState(() {
                          selectedProductCategory = newValue!;
                          _isLoading = true;
                        });
                        _getSubServiceCategory(selectedProductCategory.id);
                      },
                    ),
                  ),
                ) ,
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Sub Category',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: 10,
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.all(Radius.circular(8)),
                    border: Border.all(
                        width: 1, //
                        color: AppColors
                            .greyLightColor //            <--- border width here
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: DropdownButton<Dropdown>(
                      value: selectedSubProductCategory,
                      isExpanded: true,
                      iconEnabledColor: AppColors.primaryButtonColor,
                      items: productSubCategories.map((Dropdown value) {
                        return DropdownMenuItem<Dropdown>(
                          value: value,
                          child: Text(value.name),
                        );
                      }).toList(),
                      underline: SizedBox(
                        width: 120,
                      ),
                      icon: const Icon(Icons.keyboard_arrow_down),
                      onChanged: (Dropdown? newValue) {
                        selectedSubProductCategory = newValue!;
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Location',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: 10,
                ),
                CustomFormField(
                  controller: _locationController,
                  hintText: 'Enter location here',
                  inputType: TextInputType.text,
                ),
                SizedBox(
                  height: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stock Amount',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    CustomFormField(
                      controller: _stockController,
                      hintText: 'Enter stock amount here',
                      inputType: TextInputType.number,
                      suffixEnable: false,
                      suffixIcon: Icon(Icons.keyboard_arrow_down_outlined),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Price',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    CustomFormField(
                      controller: _priceController,
                      hintText: 'Enter price here',
                      inputType: TextInputType.number,
                      suffixEnable: false,
                      suffixIcon: Icon(Icons.keyboard_arrow_down_outlined),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),

                PrimaryButton(
                    text: 'Update Product',
                    clickCallback: _updateProduct
                ),
                SizedBox(
                  height: 50,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _updatePicture() {
    ImageSourceDialog.show(context, _selectPicture);
  }

  Future _selectPicture(int mode) async {
    if (mode == 1) {
      try {
        var image = await ImagePicker().getImage(
            source: ImageSource.camera, maxWidth: 400, maxHeight: 400);
        if (image != null) {
          _servicePhoto = File(image.path);
          setState(() {
            isUploaded = true;
          });
        }
      } on PlatformException catch (e) {
        Alerts.showMessage(context,
            "Access to the camera has been denied, please enable it to continue.");
      } catch (e) {
        Alerts.showMessage(context, e.toString());
      }
    } else {
      try {
        var image = await ImagePicker().getImage(
            source: ImageSource.gallery, maxWidth: 400, maxHeight: 400);
        if (image != null) {
          _servicePhoto = File(image.path);
          setState(() {
            isUploaded = true;
          });
          print('here');
        }
      } on PlatformException catch (e) {
        Alerts.showMessage(context,
            "Access to the gallery has been denied, please enable it to continue.");
      } catch (e) {
        Alerts.showMessage(context, e.toString());
      }
    }
  }

  void _updateProduct() async {
    String title = _titleController.text.trim();
    String info = _shortDescriptionController.text.trim();
    String des = _fullDescriptionController.text.trim();
    String loc = _locationController.text.trim();
    String price = _priceController.text.trim();
    String stock = _stockController.text.trim();

    if (!Validations.validateString(title)) {
      Alerts.showMessage(context, "Enter your title");
      return;
    }
    if (!Validations.validateString(info)) {
      Alerts.showMessage(context, "Enter your short description");
      return;
    }
    if (!Validations.validateString(des)) {
      Alerts.showMessage(context, "Enter your description");
      return;
    }
    if (!Validations.validateString(loc)) {
      Alerts.showMessage(context, "Enter your location");
      return;
    }
    if (!Validations.validateString(price)) {
      Alerts.showMessage(context, "Enter your price");
      return;
    }
    if (!Validations.validateString(stock)) {
      Alerts.showMessage(context, "Enter your stock");
      return;
    }

    setState(() {
      _isLoading = true;
    });
    ApiCalls.updateProduct(
        productId:widget.product.id,
        stock: stock,
        title: title,
        introduction: info,
        description: des,
        location: loc,
        price: price,
        catId: selectedProductCategory.id,
        subCatId: selectedSubProductCategory.id,
        picture: _servicePhoto)
        .then((response) async {
      if (!mounted) {
        return;
      }
      if (response.isSuccess) {
        Alerts.showMessage(context, "Product updated successfully.",
            title: "Success!", onCloseCallback: ()=> Navigator.pushNamedAndRemoveUntil(
                context, '/ServiceScreen', (route) => false)
        );
      } else {
        Alerts.showMessageForResponse(context, response);
        setState(() {
          _isLoading = false;
        });
      }
    });
  }
}