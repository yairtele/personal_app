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
import 'package:flutter/material.dart';
import 'ui_pages.dart';

class ShoppingParser extends RouteInformationParser<PageConfiguration> {
  @override
  Future<PageConfiguration> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location!);
    if (uri.pathSegments.isEmpty) {
      return SplashPageConfig;
    }

    final path = '/' + uri.pathSegments[0];
    switch (path) {
      case SplashPath:
        return SplashPageConfig;
      case LoginPath:
        return LoginPageConfig;
      case MoviePart1Path:
        return MoviePart1PageConfig;
      case MoviePart2Path:
        return MoviePart2PageConfig;
      case PresentationPath:
        return PresentationPageConfig;
      case FotosPath:
        return FotosPageConfig;
      case SongsPath:
        return SongsPageConfig;
      case DetailsPath:
        return DetailsPageConfig;
      case SettingsPath:
        return SettingsPageConfig;
      case NewBatchPath:
        return NewBatchPageConfig;
      case NewReturnPath:
        return NewReturnPageConfig;
      default:
        return SplashPageConfig;
    }
  }

  @override
  RouteInformation restoreRouteInformation(PageConfiguration configuration) {
    switch (configuration.uiPage) {
      case PageEnum.Splash:
        return const RouteInformation(location: SplashPath);
      case PageEnum.Login:
        return const RouteInformation(location: LoginPath);
      case PageEnum.Presentation:
        return const RouteInformation(location: PresentationPath);
      case PageEnum.Fotos:
        return const RouteInformation(location: FotosPath);
      case PageEnum.Songs:
        return const RouteInformation(location: SongsPath);
      case PageEnum.MoviePart1:
        return const RouteInformation(location: MoviePart1Path);
      case PageEnum.MoviePart2:
        return const RouteInformation(location: MoviePart2Path);
      case PageEnum.Batches:
        return const RouteInformation(location: BatchesPath);
      case PageEnum.Details:
        return const RouteInformation(location: DetailsPath);
      case PageEnum.Settings:
        return const RouteInformation(location: SettingsPath);
      case PageEnum.NewBatch:
        return const RouteInformation(location: NewBatchPath);
      case PageEnum.NewReturn:
        return const RouteInformation(location: NewReturnPath);
      case PageEnum.DetailsReturn:
        return const RouteInformation(location: DetailsReturnPath);
      case PageEnum.DetailProduct:
        return const RouteInformation(location: DetailProductPath);
      default: return const RouteInformation(location: SplashPath);

    }
  }
}