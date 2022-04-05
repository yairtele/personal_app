/*
 * Copyright (c) 2021 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import 'package:flutter/cupertino.dart';

import '../app_state.dart';

const String SplashPath = '/splash';
const String LoginPath = '/login';
const String BatchesPath = '/batches';
const String DetailsPath = '/details';
const String SettingsPath = '/settings';
const String NewBatchPath = '/newbatch';
const String NewReturnPath = '/newreturn';
const String DetailsReturnPath = '/detailsreturn';
const String DetailProductPath = '/detailproduct';
enum PageEnum {
  Splash,
  Login,
  CreateAccount,
  Batches,
  Details,
  Cart,
  Checkout,
  Settings,
  NewBatch,
  NewReturn,
  DetailsReturn,
  DetailProduct
}

class PageConfiguration {
  final String key;
  final String path;
  final PageEnum uiPage;
  PageAction? currentPageAction;

  PageConfiguration(
      {required this.key, required this.path, required this.uiPage, this.currentPageAction});
}

PageConfiguration SplashPageConfig =
    PageConfiguration(key: 'Splash', path: SplashPath, uiPage: PageEnum.Splash, currentPageAction: null);
PageConfiguration LoginPageConfig =
    PageConfiguration(key: 'Login', path: LoginPath, uiPage: PageEnum.Login, currentPageAction: null);
PageConfiguration BatchesPageConfig = PageConfiguration(
    key: 'Batches', path: BatchesPath, uiPage: PageEnum.Batches);
PageConfiguration DetailsPageConfig =
    PageConfiguration(key: 'Details', path: DetailsPath, uiPage: PageEnum.Details, currentPageAction: null);
PageConfiguration SettingsPageConfig = PageConfiguration(
    key: 'Settings', path: SettingsPath, uiPage: PageEnum.Settings, currentPageAction: null);
PageConfiguration NewBatchPageConfig = PageConfiguration(
    key: 'NewBatch', path: NewBatchPath, uiPage: PageEnum.NewBatch, currentPageAction: null);
PageConfiguration NewReturnPageConfig = PageConfiguration(
    key: 'NewReturn', path: NewReturnPath, uiPage: PageEnum.NewReturn, currentPageAction: null);
PageConfiguration DetailsReturnPageConfig = PageConfiguration(
    key: 'DetailsReturn', path: DetailsReturnPath, uiPage: PageEnum.DetailsReturn, currentPageAction: null);
PageConfiguration DetailProductPageConfig = PageConfiguration(
    key: 'DetailProduct', path: DetailProductPath, uiPage: PageEnum.DetailProduct, currentPageAction: null);

