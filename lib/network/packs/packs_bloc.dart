/*This file is part of Medito App.

Medito App is free software: you can redistribute it and/or modify
it under the terms of the Affero GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Medito App is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
Affero GNU General Public License for more details.

You should have received a copy of the Affero GNU General Public License
along with Medito App. If not, see <https://www.gnu.org/licenses/>.*/

import 'dart:async';

import 'package:Medito/network/api_response.dart';
import 'package:Medito/network/packs/packs.dart';
import 'package:Medito/network/packs/packs_repo.dart';

class PacksBloc {
  PacksRepository _repo;

  StreamController _packsListController;

  StreamSink<ApiResponse<List<PackItem>>> get packListSink =>
      _packsListController.sink;

  Stream<ApiResponse<List<PackItem>>> get packListStream =>
      _packsListController.stream;

  PacksBloc() {
    _packsListController = StreamController<ApiResponse<List<PackItem>>>();
    _repo = PacksRepository();
    fetchPacksList();
  }

  Future<void> fetchPacksList() async {
    packListSink.add(ApiResponse.loading('Fetching Packs'));
    try {
      var packs = await _repo.fetchPacks();
      packListSink.add(ApiResponse.completed(packs));
    } catch (e) {
      packListSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  void dispose() {
    _packsListController?.close();
  }
}