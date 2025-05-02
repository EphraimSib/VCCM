import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

class BlockchainService {
  final String rpcUrl;
  final String privateKey;
  late Web3Client _client;
  late EthPrivateKey _credentials;
  late DeployedContract _contract;

  BlockchainService(this.rpcUrl, this.privateKey);

  Future<void> init(String contractAddress, String abi) async {
    _client = Web3Client(rpcUrl, Client());
    _credentials = EthPrivateKey.fromHex(privateKey);
    _contract = DeployedContract(ContractAbi.fromJson(abi, 'SecurityLog'), EthereumAddress.fromHex(contractAddress));
  }

  Future<String> addLog(String eventDescription) async {
    final addLogFunction = _contract.function('addLog');
    final result = await _client.sendTransaction(
      _credentials,
      Transaction.callContract(
        contract: _contract,
        function: addLogFunction,
        parameters: [eventDescription],
      ),
      fetchChainIdFromNetworkId: true,
    );
    return result;
  }

  Future<int> getLogCount() async {
    final getLogCountFunction = _contract.function('getLogCount');
    final result = await _client.call(
      contract: _contract,
      function: getLogCountFunction,
      params: [],
    );
    return (result[0] as BigInt).toInt();
  }

  Future<Map<String, dynamic>> getLog(int index) async {
    final getLogFunction = _contract.function('getLog');
    final result = await _client.call(
      contract: _contract,
      function: getLogFunction,
      params: [BigInt.from(index)],
    );
    return {
      'timestamp': (result[0] as BigInt).toInt(),
      'eventDescription': result[1] as String,
      'reporter': result[2] as EthereumAddress,
    };
  }
}
