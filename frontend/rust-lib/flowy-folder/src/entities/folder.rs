use flowy_derive::ProtoBuf;

use super::RepeatedViewPB;

#[derive(Default, ProtoBuf)]
pub struct FolderPB {
  #[pb(index = 1)]
  pub all_views: RepeatedViewPB,

  #[pb(index = 2)]
  pub all_public_views: RepeatedViewPB,

  #[pb(index = 3)]
  pub all_private_views: RepeatedViewPB,

  #[pb(index = 4)]
  pub all_trash_views: RepeatedViewPB,

  #[pb(index = 5)]
  pub my_private_view: RepeatedViewPB,

  #[pb(index = 6)]
  pub my_trash_views: RepeatedViewPB,
}
