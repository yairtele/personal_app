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

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:navigation_app/ui/newbatch.dart';
import '../ui/newbatch.dart';
import '../app_state.dart';
import '../ui/batches.dart';
import '../ui/login.dart';
import '../ui/settings.dart';
import '../ui/splash.dart';
import 'back_dispatcher.dart';
import 'ui_pages.dart';

class ShoppingRouterDelegate extends RouterDelegate<PageConfiguration>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<PageConfiguration> {
  final List<Page> _pages = [];
  late ShoppingBackButtonDispatcher backButtonDispatcher;

  @override
  final GlobalKey<NavigatorState> navigatorKey;
  final AppState appState;

  ShoppingRouterDelegate(this.appState) : navigatorKey = GlobalKey() {
    appState.addListener(() {
      notifyListeners();
    });
  }

  /// Getter for a list that cannot be changed
  List<MaterialPage> get pages => List.unmodifiable(_pages);

  /// Number of pages function
  int numPages() => _pages.length;

  @override
  PageConfiguration get currentConfiguration {
    print('currentConfiguration - enter');
    print(appState.currentAction.state);
    print(appState.currentAction.pageConfig);
    print(appState.currentAction.widget);
    if(appState.currentAction.pageConfig != null){
      return appState.currentAction.pageConfig!;
    }

    print((_pages.last.arguments as PageConfiguration).path);
    return _pages.last.arguments as PageConfiguration;
  }

  @override
  Widget build(BuildContext context) {
    print('build - enter');
    return Navigator(
      key: navigatorKey,
      onPopPage: _onPopPage,
      pages: buildPages(context),
    );
  }

  bool _onPopPage(Route<dynamic> route, result) {
    print('_onPopPage - enter');
    final didPop = route.didPop(result);
    if (!didPop) {
      return false;
    }
    if (canPop()) {
      print('can pop');
      pop();
      print('poped');
      return true;
    } else {
      print('cannot pop');
      return false;
    }
  }

  void _removePage(Page? page) {
    if (page != null) {
      _pages.remove(page);
    }
  }

  //TODO: ver si 'result' se puede tipar con Generics
  void pop([result]) {
    if (canPop()) {
      final pageConfig = _pages.last.arguments as PageConfiguration; //TODO: ver si PageConfiguration se puede tipar con Generics, con el mismo tipo del parámetro 'result'
      _removePage(_pages.last);
      if(pageConfig.currentPageAction != null && pageConfig.currentPageAction!.returnValueCompleter != null && result != null){
        pageConfig.currentPageAction!.returnValueCompleter!.complete(result);
      }
      else {
        notifyListeners();
      }
    }
  }

  bool canPop() {
    return _pages.length > 1;
  }

  @override
  Future<bool> popRoute() {
    if (canPop()) {
      _removePage(_pages.last);
      return Future.value(true);
    }
    return Future.value(false);
  }

  MaterialPage _createPage(Widget child, PageConfiguration pageConfig) {
    return MaterialPage(
        child: child,
        key: ValueKey(pageConfig.key),
        name: pageConfig.path,
        arguments: pageConfig);
  }

  void _addPageData(Widget child, PageConfiguration pageConfig) {
    print('_addPageData - enter');
    print(pageConfig.path);
    _pages.add(
      _createPage(child, pageConfig),
    );
    print('_addPageData - exit');
  }

  void addPage(PageConfiguration pageConfig) {
    final shouldAddPage = _pages.isEmpty ||
        (_pages.last.arguments as PageConfiguration).uiPage !=
            pageConfig.uiPage;
    if (shouldAddPage) {
      switch (pageConfig.uiPage) {
        case PageEnum.Splash:
          _addPageData(Splash(), SplashPageConfig);
          break;
        case PageEnum.Login:
          _addPageData(Login(), LoginPageConfig);
          break;
        case PageEnum.Batches:
          _addPageData(const Batches(), BatchesPageConfig);
          break;
        case PageEnum.Settings:
          _addPageData(Settings(), SettingsPageConfig);
          break;
        case PageEnum.NewBatch:
          //_addPageData(NewBatch(returnValueCompleter: Completer<bool>()), NewBatchPageConfig);
          _addPageData(const NewBatch(), NewBatchPageConfig);
          break;
        case PageEnum.NewReturn:
          if (pageConfig.currentPageAction != null) {
            _addPageData(pageConfig.currentPageAction!.widget!, pageConfig);
          }
          break;
        case PageEnum.DetailsReturn:
          if (pageConfig.currentPageAction != null) {
            _addPageData(pageConfig.currentPageAction!.widget!, pageConfig);
          }
          break;
        case PageEnum.DetailProduct:
          if (pageConfig.currentPageAction != null) {
            _addPageData(pageConfig.currentPageAction!.widget!, pageConfig);
          }
          break;
        case PageEnum.Details:
          if (pageConfig.currentPageAction != null) {
            _addPageData(pageConfig.currentPageAction!.widget!, pageConfig);
          }
          break;
        default:
          break;
      }
    }
  }

  void replace(PageConfiguration newRoute) {
    if (_pages.isNotEmpty) {
      _pages.removeLast();
    }
    addPage(newRoute);
  }

  void setPath(List<MaterialPage> path) {
    _pages.clear();
    _pages.addAll(path);
  }

  void replaceAll(PageConfiguration newRoute) {
    setNewRoutePath(newRoute);
  }

  void push(PageConfiguration newRoute) {
    addPage(newRoute);
  }

  void pushWidget(Widget child, PageConfiguration newRoute) {
    _addPageData(child, newRoute);
  }

  void addAll(List<PageConfiguration> routes) {
    _pages.clear();
    routes.forEach((route) {
      addPage(route);
    });
  }

  @override
  Future<void> setNewRoutePath(PageConfiguration configuration) {
    final shouldAddPage = _pages.isEmpty ||
        (_pages.last.arguments as PageConfiguration).uiPage !=
            configuration.uiPage;
    if (shouldAddPage) {
      _pages.clear();
      addPage(configuration);
    }
    return SynchronousFuture(null);
  }

  void _setPageAction(PageAction action) {
    switch (action.pageConfig!.uiPage) {
      case PageEnum.Splash:
        SplashPageConfig.currentPageAction = action;
        break;
      case PageEnum.Login:
        LoginPageConfig.currentPageAction = action;
        break;
      case PageEnum.Batches:
        BatchesPageConfig.currentPageAction = action;
        break;
      case PageEnum.Settings:
        SettingsPageConfig.currentPageAction = action;
        break;
      case PageEnum.Details:
        DetailsPageConfig.currentPageAction = action;
        break;
      case PageEnum.NewBatch:
        NewBatchPageConfig.currentPageAction = action;
        break;
      case PageEnum.NewReturn:
        NewReturnPageConfig.currentPageAction = action;
        break;
      case PageEnum.DetailsReturn:
        DetailsReturnPageConfig.currentPageAction = action;
        break;
      case PageEnum.DetailProduct:
        DetailProductPageConfig.currentPageAction = action;
        break;
      default:
        break;
    }
  }

  List<Page> buildPages(BuildContext context) {
    if (!appState.splashFinished) {
      replaceAll(SplashPageConfig);
    } else {
      switch (appState.currentAction.state) {
        case PageState.none:
          break;
        case PageState.addPage:
          _setPageAction(appState.currentAction);
          addPage(appState.currentAction.pageConfig!);
          break;
        case PageState.pop:
          pop(appState.currentAction.returnValue);
          break;
        case PageState.replace:
          _setPageAction(appState.currentAction);
          replace(appState.currentAction.pageConfig!);
          break;
        case PageState.replaceAll:
          _setPageAction(appState.currentAction);
          replaceAll(appState.currentAction.pageConfig!);
          break;
        case PageState.addWidget:
          _setPageAction(appState.currentAction);
          pushWidget(appState.currentAction.widget!, appState.currentAction.pageConfig!);
          break;
        case PageState.addAll:
          addAll(appState.currentAction.pages!);
          break;
      }
    }
    appState.resetCurrentAction();
    return List.of(_pages);
  }


  void parseRoute(Uri uri) {
    if (uri.pathSegments.isEmpty) {
      setNewRoutePath(SplashPageConfig);
      return;
    }

    // Handle navapp://deeplinks/details/#
    if (uri.pathSegments.length == 2) {
      if (uri.pathSegments[0] == 'details') {
        //TODO:Arreglar esta y todas las rutas
        //pushWidget(const BatchDetails(batch: null), DetailsPageConfig);
      }
    } else if (uri.pathSegments.length == 1) {
      final path = uri.pathSegments[0];
      switch (path) {
        case 'splash':
          replaceAll(SplashPageConfig);
          break;
        case 'login':
          replaceAll(LoginPageConfig);
          break;
        case 'Batches':
          replaceAll(BatchesPageConfig);
          break;
        case 'settings':
          setPath([
            _createPage(Batches(), BatchesPageConfig),
            _createPage(Settings(), SettingsPageConfig)
          ]);
          break;
        case 'newbatch':
          setPath([
            _createPage(Batches(), BatchesPageConfig),
            _createPage(NewBatch(), NewBatchPageConfig)
          ]);
          break;
        case 'newreturn':
          throw Exception('Parseo de ruta para newreturn no implementada.');
          //setPath([
          //  _createPage(Batches(), ListItemsPageConfig),
          //  _createPage(NewReturnScreen(), NewBatchPageConfig)
          //]);
      }
    }
  }
}
