import 'package:appflowy/plugins/document/presentation/editor_plugins/table/shortcuts/simple_table_arrow_down_command.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/table/shortcuts/simple_table_arrow_left_command.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/table/shortcuts/simple_table_arrow_right_command.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/table/shortcuts/simple_table_arrow_up_command.dart';

export 'simple_table_arrow_down_command.dart';
export 'simple_table_arrow_up_command.dart';

final simpleTableCommands = [
  arrowUpInTableCell,
  arrowDownInTableCell,
  arrowLeftInTableCell,
  arrowRightInTableCell,
];
