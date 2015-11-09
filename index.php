<pre style="display: none">
<?php
  $fh = fopen('linkmap.tsv','r');
  $links = array();
  while($row = fgetcsv($fh, 10000, "\t")) {
    $links[$row[0]] = $row[1];
  }

  $fh = fopen('songs.tsv','r');
  $songs = array();
  while($row = fgetcsv($fh, 10000, "\t", "\0")) {
    $songs[] = $row;
  }
?>
</pre>
<html>
  <head>
    <title>Most of the #1 Billboard Hits I could find on Wikipedia</title>
    <script type="text/javascript" src="http://code.jquery.com/jquery-2.1.4.js"></script>
    <link rel="stylesheet" href="//cdn.datatables.net/1.10.9/css/jquery.dataTables.min.css"/>
    <link rel="stylesheet" href="//cdn.datatables.net/1.10.9/css/jquery.dataTables.min.css"/>
    <script type="text/javascript" src="//cdn.datatables.net/1.10.9/js/jquery.dataTables.min.js"></script>
  </head>
  <body>
    <table>
      <thead>
        <tr>
          <th>Artist</th>
          <th>Song</th>
          <th>Source chart(s)</th>
      </thead>
      <tbody>
        <?php foreach($songs as $row): ?>
        <tr>
          <td><?=$row[0]?></td>
          <td><?=$row[1]?></td>
          <td style="position: relative">
            <a href="" class="refcount">[<?=count($row[2])?>]</a>
          </td>
        </tr>
        <?php endforeach ?>
      </tbody>
    </table>
    <script type="text/javascript">
      $('table').DataTable({
        dom: 'flrtip',
        lengthMenu: [100,500,1000,5000],
        language: {
          search: 'Search by song, artist, or chart:',
        }
      }); 
    </script>
  </body>
</html>
