use std::sync::{Arc, Weak};

use collab_integrate::collab_builder::AppFlowyCollabBuilder;
use collab_integrate::RocksCollabDB;
use flowy_database2::DatabaseManager;
use flowy_document2::manager::{DocumentFolder, DocumentManager, DocumentUser};
use flowy_document_deps::cloud::DocumentCloudService;
use flowy_error::{FlowyError, FlowyResult};
use flowy_folder2::{entities::UpdateViewParams, manager::FolderManager};
use flowy_folder_deps::cloud::Folder;
use flowy_storage::FileStorageService;
use flowy_user::manager::UserManager;

pub struct DocumentDepsResolver();
impl DocumentDepsResolver {
  pub fn resolve(
    user_manager: Weak<UserManager>,
    // folder_manager: Weak<FolderManager>,
    _database_manager: &Arc<DatabaseManager>,
    collab_builder: Arc<AppFlowyCollabBuilder>,
    cloud_service: Arc<dyn DocumentCloudService>,
    storage_service: Weak<dyn FileStorageService>,
  ) -> Arc<DocumentManager> {
    let user: Arc<dyn DocumentUser> = Arc::new(DocumentUserImpl(user_manager));
    Arc::new(DocumentManager::new(
      user.clone(),
      // folder_manager.clone(),
      collab_builder,
      cloud_service,
      storage_service,
    ))
  }
}

// struct FolderManagerImpl(Weak<FolderManager>);
// impl DocumentFolder for FolderManagerImpl {
//   fn update_view_with_doc_id(&self, doc_id: String) -> FlowyResult<()> {
//     self
//       .0
//       .upgrade()
//       .ok_or(FlowyError::internal().with_context("FolderManager is None"))?
//       .update_view_last_edited_time(UpdateViewParams {
//         view_id: doc_id,
//         ..Default::default()
//       })
//   }
// }

struct DocumentUserImpl(Weak<UserManager>);
impl DocumentUser for DocumentUserImpl {
  fn user_id(&self) -> Result<i64, FlowyError> {
    self
      .0
      .upgrade()
      .ok_or(FlowyError::internal().with_context("Unexpected error: UserSession is None"))?
      .user_id()
  }

  fn workspace_id(&self) -> Result<String, FlowyError> {
    self
      .0
      .upgrade()
      .ok_or(FlowyError::internal().with_context("Unexpected error: UserSession is None"))?
      .workspace_id()
  }

  fn token(&self) -> Result<Option<String>, FlowyError> {
    self
      .0
      .upgrade()
      .ok_or(FlowyError::internal().with_context("Unexpected error: UserSession is None"))?
      .token()
  }

  fn collab_db(&self, uid: i64) -> Result<Weak<RocksCollabDB>, FlowyError> {
    self
      .0
      .upgrade()
      .ok_or(FlowyError::internal().with_context("Unexpected error: UserSession is None"))?
      .get_collab_db(uid)
  }
}
